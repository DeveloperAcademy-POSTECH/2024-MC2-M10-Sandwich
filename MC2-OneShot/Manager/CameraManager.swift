import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    
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

// 사진 캡처 델리게이트
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        let currentPosition = videoDeviceInput.device.position
        
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: imageData) {
            // 현재 디바이스 방향을 가져옴
            let deviceOrientation = UIDevice.current.orientation
            let radians: CGFloat
            
            // 디바이스 방향에 따라 회전 각도 설정
            switch deviceOrientation {
            case .landscapeLeft:
                radians = currentPosition == .front ? .pi / 2 : -.pi / 2
            case .landscapeRight:
                radians = currentPosition == .front ? -.pi / 2 : .pi / 2
            case .portraitUpsideDown:
                radians = .pi
            default:
                radians = 0
            }
            
            // 이미지 회전 적용
            var finalImage = image.rotate(radians: radians) ?? image
            
            // 전면 카메라일 경우 이미지 좌우 반전
            if currentPosition == .front {
                finalImage = flipImageHorizontally(finalImage) ?? finalImage
            }
            
            self.recentImage = finalImage
        }
            
        print("Capture 끝!")
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings, error: Error?) {
        
        // 1. 사진 캡처 완료
        isPhotoCaptureDone = true
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // AudioServicesDisposeSystemSoundID(1108)
        
    }
    func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // AudioServicesDisposeSystemSoundID(1108)
    }
}
