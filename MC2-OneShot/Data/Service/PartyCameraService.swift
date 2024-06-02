//
//  CameraService.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//

import SwiftUI
import AVFoundation

// MARK: - PartyCameraService

final class PartyCameraService: NSObject, PartyCameraInterface {

    /// Input과 Output을 연결하는 Session
    private var session = AVCaptureSession()
    
    /// 실제 디바이스 연결을 통한 Input
    private var input: AVCaptureDeviceInput!
    
    /// 촬영 이후 결과를 내보내는 Output
    private let output = AVCapturePhotoOutput()
    
    /// 카메라 관련 동작은 SessionQueue에서 진행
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    
    /// 가장 마지막에 촬영한 사진 UIImage
    private var recentImage: UIImage?
}

// MARK: - 프로토콜 구현체

extension PartyCameraService {
    
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
    func capturePhoto() {
        output.capturePhoto(with: capturePhotoSetting, delegate: self)
    }
    
    /// 사진 저장을 위해 이미지 데이터를 반환합니다.
    func fetchPhotoDataForSave() -> Data? {
        guard let recentImage = recentImage,
              let croppedImage = cropImageToSquare(image: recentImage) else { return nil }
        return croppedImage.jpegData(compressionQuality: 1.0)
    }
    
    /// 전면 / 후면 카메라를 전환합니다.
    func toggleFrontBack() {
        //
    }
    
    /// 플래시 모드를 전환합니다.
    func toggleFlashMode() {
        //
    }
}

// MARK: - AVCaptureSession 구현

extension PartyCameraService {
    
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
    
    /// AVCapturePhotoSetting을 반환합니다.
    private var capturePhotoSetting: AVCapturePhotoSettings {
        return AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
    }
}

// MARK: - AVCapturePhotoCaptureDelegate

extension PartyCameraService: AVCapturePhotoCaptureDelegate {
    
    /// 사진 촬영 후 Photo 데이터의 준비가 완료되었을 때 호출되는 Delegate 메서드
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let uiImage = UIImage(data: imageData) else {
            print("photoOutput(didFinishProcessingPhoto:) - Photo 데이터 변환 실패 ")
            return
        }
        
        let devicePosition = input.device.position
        if devicePosition == .front { self.recentImage = flipImageHorizontally(uiImage) }
        else { self.recentImage = uiImage }
    }
}

// MARK: - Camera Preview 구현

extension PartyCameraService {
    
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

extension PartyCameraService {
    
    /// 이미지를 좌우반전 후 반환합니다.
    private func flipImageHorizontally(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
        
        context.scaleBy(x: -1.0, y: 1.0)
        
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        
        image.draw(at: .zero)
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
    
    /// 이미지를 정사각형 모양으로 자르는 함수
    private func cropImageToSquare(image: UIImage) -> UIImage? {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let aspectRatio = width / height
        var rect: CGRect
        
        if aspectRatio > 1 {
            rect = CGRect(x: (width - height) / 2, y: 0, width: height, height: height)
        } else {
            rect = CGRect(x: 0, y: (height - width) / 2, width: width, height: width)
        }
        
        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return nil
    }
}

class OldPartyCameraService: NSObject, ObservableObject {
    
    var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let output = AVCapturePhotoOutput()
    
    @Published var recentImage: UIImage?
    @Published var isPhotoCaptureDone = false
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
    // 카메라 셋업 과정을 담당하는 함수
    func setUpCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        sessionQueue.async { [weak self] in
            
            guard let self = self else { return }
            do {
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                addInputToSession(input: videoDeviceInput)
                addOutputToSession(output: output)
                startSession()
            } catch {
                print("Error setting up camera: \(error)")
            }
        }
    }
    
    // 카메라 권한 요청 및 상태 확인
    func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    self?.setUpCamera()
                }
            }
        case .restricted, .denied:
            print("권한 거부 / 제한")
        case .authorized:
            setUpCamera()
        @unknown default:
            print("알수없는 권한 상태")
        }
    }
    
    // 사진 캡처
    func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
        output.capturePhoto(with: photoSettings, delegate: self)
        
        print("사진 캡쳐")
    }
    
    // 화면 다시 촬영
    func retakePhoto() {
        isPhotoCaptureDone = false
        // startSession()
    }
    
    // 카메라 전환
    func changeCamera() {
        let currentPosition = videoDeviceInput.device.position
        let preferredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        
        print(preferredPosition == .back ? "후면카메라로 전환합니다." : "전면카메라로 전환합니다.")
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferredPosition) else {
            print("videoDevice 객체 생성 실패")
            return
        }
        
        sessionQueue.async { [weak self] in
            do {
                guard let self = self else { return }
                
                let newVideoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                session.beginConfiguration()
                session.removeInput(videoDeviceInput)
                addInputToSession(input: newVideoDeviceInput)
                videoDeviceInput = newVideoDeviceInput
                session.commitConfiguration()
                
                print("잘 전환됨")
            } catch {
                print("Error changing camera: \(error)")
            }
        }
    }
    
    // 이미지 좌우반전
    func flipImageHorizontally(_ image: UIImage) -> UIImage? {
        UIGraphicsBeginImageContext(image.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        context.translateBy(x: image.size.width / 2, y: image.size.height / 2)
        
        context.scaleBy(x: -1.0, y: 1.0)
        
        context.translateBy(x: -image.size.width / 2, y: -image.size.height / 2)
        
        image.draw(at: .zero)
        
        let flippedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return flippedImage
    }
    
    // 세션 시작
    private func startSession() {
        sessionQueue.async {
            self.session.startRunning()
        }
    }
    
    // 세션 정지
    private func stopSession() {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    // 세션에 입력 추가
    private func addInputToSession(input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            print("Input이 추가되지 않음")
        }
    }
    
    // 세션에 출력 추가
    private func addOutputToSession(output: AVCapturePhotoOutput) {
        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            print("Output이 추가되지 않음")
        }
    }
}

// 사진 캡처 델리게이트
extension OldPartyCameraService: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        let currentPosition = videoDeviceInput.device.position
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if currentPosition == .front {
            if let image = UIImage(data: imageData) {
                self.recentImage = flipImageHorizontally(image) // 최근 사진 반영
            }
        } else {
            if let image = UIImage(data: imageData) {
                self.recentImage = image // 최근 사진 반영
            }
        }
        
        print("Capture 끝!")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        // 1. 사진 캡처 완료
        isPhotoCaptureDone = true
    }
}
