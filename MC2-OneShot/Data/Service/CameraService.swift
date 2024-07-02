//
//  CameraService.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//

import SwiftUI
import Combine
import AVFoundation

// MARK: - CameraService

final class CameraService: NSObject, CameraServiceInterface {
    
    /// Input과 Output을 연결하는 Session
    private var session = AVCaptureSession()
    
    /// 실제 디바이스 연결을 통한 Input
    private var input: AVCaptureDeviceInput!
    
    /// 촬영 이후 결과를 내보내는 Output
    private let output = AVCapturePhotoOutput()
    
    /// 카메라 관련 동작은 SessionQueue에서 진행
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    /// 가장 마지막에 촬영한 사진 CapturePhoto
    private var recentPhoto: CapturePhoto?
    
    /// 사진 데이터 준비 후 실행되는 Completion Handler
    private var photoDataPrepare: ((CapturePhoto?) -> Void)?
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
    }
}

// MARK: - Protocol Implementation

extension CameraService {
    
    /// 카메라 권한을 요청합니다.
    func requestPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined: requestAccess()
        case .restricted, .denied: print("권한 거부 / 제한")
        case .authorized: initialSetup()
        @unknown default: print("알수없는 권한 상태")
        }
    }
    
    /// Camera 화면에 보여질 Preview 객체를 반환합니다.
    func displayPreview() -> AnyView {
        return AnyView(CameraPreviewView(session: session))
    }
    
    /// 사진을 촬영합니다.
    func capturePhoto(photoDataPrepare: @escaping (CapturePhoto?) -> Void) {
        self.photoDataPrepare = photoDataPrepare
        output.capturePhoto(with: capturePhotoSetting, delegate: self)
    }
    
    /// 사진 저장을 위해 이미지 데이터를 반환합니다.
    func fetchPhotoDataForSave() -> CapturePhoto? {
        guard let recentImage = recentPhoto?.image,
              let croppedPhoto = cropImageToSquare(image: recentImage),
              let imageData = croppedPhoto.image.jpegData(compressionQuality: 1.0),
              let uiImage = UIImage(data: imageData)
        else {
            print("이미지 데이터 반환에 실패했습니다.")
            return nil
        }
        
        return CapturePhoto(image: uiImage)
    }
    
    /// 전면 / 후면 카메라를 전환합니다.
    func toggleFrontBack() {
        let currentPosition = input.device.position
        
        let preferredPosition: AVCaptureDevice.Position = (
            currentPosition == .back
        ) ? .front : .back
        
        guard let videoDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video, position: preferredPosition
        ) else {
            print("videoDevice 객체 생성 실패")
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                guard let self = self else { return }
                
                let newVideoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                session.beginConfiguration()
                session.removeInput(input)
                addInputToSession(input: newVideoDeviceInput)
                input = newVideoDeviceInput
                session.commitConfiguration()
            } catch {
                print("Error changing camera: \(error)")
            }
        }
    }
    
    /// 플래시 모드를 전환합니다.
    func toggleFlashMode() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        guard device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = device.isTorchActive ? .off : .on
            device.unlockForConfiguration()
        } catch {
            print("플래시를 제어할 수 없습니다: \(error)")
        }
    }
    
    /// 디바이스 회전 각도를 반환합니다.
    func rotationAngle(orientation: UIDeviceOrientation) -> Angle {
        switch orientation {
        case .landscapeLeft:
            return .degrees(90)
        case .landscapeRight:
            return .degrees(-90)
        case .portraitUpsideDown:
            return .degrees(180)
        default:
            return .degrees(0)
        }
    }
    
    /// 방향이 변경될 때마다 호출되는 Publisher를 반환합니다.
    func orientationChange() -> AnyPublisher<UIDeviceOrientation, Never> {
        let notificationCenter = NotificationCenter.default
        
        // 디바이스 방향 변경 알림을 활성
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        return notificationCenter
            .publisher(for: UIDevice.orientationDidChangeNotification)
            .compactMap { _ in
                UIDevice.current.orientation
            }
            .eraseToAnyPublisher()
    }
      
    /// 일반 줌 배열로 전환합니다.
    func generalAngle() {
        guard let  generalAngleDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera, for: .video, position: .unspecified
        ) else {
            print("videoDevice 객체 생성 실패")
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                guard let self = self else { return }
                
                let newVideoDeviceInput = try AVCaptureDeviceInput(device: generalAngleDevice)
                
                session.beginConfiguration()
                session.removeInput(input)
                addInputToSession(input: newVideoDeviceInput)
                input = newVideoDeviceInput
                session.commitConfiguration()
            } catch {
                print("Error changing camera: \(error)")
            }
        }
    }
    
    /// 광각 모드로 전환합니다.
    func wideAngle() {
        guard let  WideAngleDevice = AVCaptureDevice.default(
            .builtInUltraWideCamera, for: .video, position: .unspecified
        ) else {
            print("videoDevice 객체 생성 실패")
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                guard let self = self else { return }
                
                let newVideoDeviceInput = try AVCaptureDeviceInput(device: WideAngleDevice)
                
                session.beginConfiguration()
                session.removeInput(input)
                addInputToSession(input: newVideoDeviceInput)
                input = newVideoDeviceInput
                session.commitConfiguration()
            } catch {
                print("Error changing camera: \(error)")
            }
        }
    }
    
    /// 줌 배율을 조절합니다.
    func zoom(currentZoomFactor: CGFloat, delta: CGFloat) -> CGFloat {
        let device = input.device
        
        // 하드웨어 최대 줌 배율
        // let maxZoomFactor = device.activeFormat.videoMaxZoomFactor
        
        let maxZoomFactor : CGFloat = 5
        
        let newScale = min(max(currentZoomFactor * delta, 1), maxZoomFactor)
        let zoomFactor = newScale < 1 ? 1 : newScale
        
        do {
            try device.lockForConfiguration()
            device.videoZoomFactor = zoomFactor
            device.unlockForConfiguration()
        }
        catch {
            print(error.localizedDescription)
        }
        
        return newScale
    }
    
}

// MARK: - AVCaptureSession 구현

extension CameraService {
    
    /// 카메라 사용 권한을 요청합니다.
    private func requestAccess() {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
            if authStatus { self?.initialSetup() }
        }
    }
    
    /// 카메라 초기 설정 메서드입니다.
    private func initialSetup() {
        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else { return }
        
        sessionQueue.async { [weak self] in
            
            guard let self = self else { return }
            do {
                input = try AVCaptureDeviceInput(device: device)
                addInputToSession(input: input)
                addOutputToSession(output: output)
                startSession()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    /// AVCaptureSession에 입력(Input)을 추가합니다.
    private func addInputToSession(input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Input이 추가되지 않음")
        }
    }
    
    /// AVCaptureSession에 출력(Output)을 추가합니다.
    private func addOutputToSession(output: AVCapturePhotoOutput) {
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            print("Output이 추가되지 않음")
        }
    }
    
    /// AVCaptureSession을 시작합니다.
    private func startSession() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    /// AVCaptureSession을 정지합니다.
    private func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    /// AVCapturePhotoSetting을 반환합니다.
    private var capturePhotoSetting: AVCapturePhotoSettings {
        return AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension CameraService: AVCapturePhotoCaptureDelegate {
    
    /// 사진 촬영 후 Photo 데이터의 준비가 완료되었을 때 호출되는 Delegate 메서드
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("photoOutput(didFinishProcessingPhoto:) - Photo 데이터 변환 실패 ")
            return
        }
        
        // 현재 화면 위치(전면/후면)를 가져옴
        let devicePosition = input.device.position
        // 현재 디바이스 방향(각도)을 가져옴
        let deviceOrientation = UIDevice.current.orientation
        let radians: CGFloat
        
        // 디바이스 방향에 따라 회전 각도 설정
        switch deviceOrientation {
        case .landscapeLeft:
            radians = devicePosition == .front ? .pi / 2 : -.pi / 2
        case .landscapeRight:
            radians = devicePosition == .front ? -.pi / 2 : .pi / 2
        case .portraitUpsideDown:
            radians = .pi
        default:
            radians = 0
        }
        
        // 이미지 회전 적용
        var finalImage = uiImage.rotate(radians: radians) ?? uiImage
        
        // 전면 카메라일 경우 이미지 좌우 반전
        if devicePosition == .front {
            finalImage = flipImageHorizontally(finalImage)?.image ?? uiImage
        }
        
        self.recentPhoto = CapturePhoto(image:finalImage)
        
        photoDataPrepare?(recentPhoto)
    }
    
    /// 카메라 촬영음 음소거
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) { AudioServicesDisposeSystemSoundID(1108) }
    
    /// 카메라 촬영음 음소거
    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings
    ) { AudioServicesDisposeSystemSoundID(1108) }
}

// MARK: - Camera Preview 구현

extension CameraService {
    
    /// CameraPreview 객체
    private struct CameraPreviewView: UIViewRepresentable {
        
        let session: AVCaptureSession
        
        class VideoPreviewView: UIView {
            override class var layerClass: AnyClass {
                AVCaptureVideoPreviewLayer.self
            }
            
            var videoPreviewLayer: AVCaptureVideoPreviewLayer {
                return layer as! AVCaptureVideoPreviewLayer
            }
        }
        
        func makeUIView(context: Context) -> VideoPreviewView {
            let view = VideoPreviewView()
            view.videoPreviewLayer.session = session
            view.backgroundColor = .black
            view.videoPreviewLayer.videoGravity = .resizeAspectFill
            view.videoPreviewLayer.cornerRadius = 0
            view.videoPreviewLayer.connection?.videoRotationAngle = 90
            return view
        }
        
        func updateUIView(_ uiView: VideoPreviewView, context: Context) {}
    }
}

// MARK: - Camera Additional Method

extension CameraService {
    
    /// 이미지를 좌우반전 후 반환합니다.
    private func flipImageHorizontally(_ image: UIImage) -> CapturePhoto? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(
            x: image.size.width / 2,
            y: image.size.height / 2
        )
        
        context.scaleBy(x: -1.0, y: 1.0)
        
        context.translateBy(
            x: -image.size.width / 2,
            y: -image.size.height / 2
        )
        
        image.draw(at: .zero)
        
        guard let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        else { return nil }
        
        UIGraphicsEndImageContext()
        
        return CapturePhoto(image: flippedImage)
    }
    
    /// 이미지를 정사각형 모양으로 자르는 함수
    private func cropImageToSquare(image: UIImage) -> CapturePhoto? {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let aspectRatio = width / height
        var rect: CGRect
        
        if aspectRatio > 1 {
            rect = CGRect(
                x: (width - height) / 2,
                y: 0, width: height,
                height: height
            )
            
        } else {
            rect = CGRect(
                x: 0,
                y: (height - width) / 2,
                width: width,
                height: width
            )
        }
        
        if let croppedCGImage = cgImage.cropping(to: rect) {
            let uiImage = UIImage(
                cgImage: croppedCGImage,
                scale: image.scale,
                orientation: image.imageOrientation
            )
            return CapturePhoto(image: uiImage)
        }
        
        return nil
    }
}

// MARK: - UIImage Additional Method

extension UIImage {
    
    // 이미지를 주어진 라디안 각도로 회전
    func rotate(radians: CGFloat) -> UIImage? {
        var newSize = CGRect(origin: CGPoint.zero, size: self.size).applying(CGAffineTransform(rotationAngle: radians)).size
        
        newSize.width = floor(newSize.width)
        newSize.height = floor(newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, self.scale)
        let context = UIGraphicsGetCurrentContext()!
        
        
        context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
        
        context.rotate(by: radians)
        self.draw(in: CGRect(x: -self.size.width / 2, y: -self.size.height / 2, width: self.size.width, height: self.size.height))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
}
