//
//  CameraManager.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//
import SwiftUI
import AVFoundation

class CameraManager: NSObject, ObservableObject {
    static let shared = CameraManager()
    private override init() {}
    
    var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let output = AVCapturePhotoOutput()
    
    @Published var isShot = false
    @Published var recentImage: UIImage?
    
    // 카메라 셋업 과정을 담당하는 함수
    func setUpCamera() {
        guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        do {
            videoDeviceInput = try AVCaptureDeviceInput(device: device)
            addInputToSession(input: videoDeviceInput)
            addOutputToSession(output: output)
            startSession()
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    // 카메라 권한 요청 및 상태 확인
    func requestAndCheckPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
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
        let photoSettings = AVCapturePhotoSettings()
        output.capturePhoto(with: photoSettings, delegate: self)
        print("사진 캡쳐")
    }
    
    // 화면 다시 촬영
    func retakePhoto() {
        startSession()
    }
    
    // 카메라 전환
    func changeCamera() {
        let currentPosition = videoDeviceInput.device.position
        let preferredPosition: AVCaptureDevice.Position = (currentPosition == .back) ? .front : .back
        
        print(preferredPosition == .back ? "후면카메라로 전환합니다." : "전면카메라로 전환합니다.")
        
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: preferredPosition) else { return }
        
        do {
            let newVideoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            session.beginConfiguration()
            session.removeInput(videoDeviceInput)
            addInputToSession(input: newVideoDeviceInput)
            videoDeviceInput = newVideoDeviceInput
            session.commitConfiguration()
        } catch {
            print("Error changing camera: \(error)")
        }
    }
    
    // 세션 시작
    private func startSession() {
        DispatchQueue.global(qos: .background).async {
            self.session.startRunning()
        }
    }
    
    // 세션에 입력 추가
    private func addInputToSession(input: AVCaptureDeviceInput) {
        if session.canAddInput(input) {
            session.addInput(input)
        }
    }
    
    // 세션에 출력 추가
    private func addOutputToSession(output: AVCapturePhotoOutput) {
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
    }
}

// 사진 캡처 델리게이트
extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: imageData) {
            self.recentImage = image // 최근 사진 반영
        }
        
        DispatchQueue.global(qos: .background).async {
            self.session.stopRunning() // 화면 멈춤
        }
        
        isShot = true
        
        print("Capture 끝!")
    }
}
