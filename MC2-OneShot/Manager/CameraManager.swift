//
//  CameraManager.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//
import SwiftUI
import AVFoundation

// NSObject 추가
class CameraManager: NSObject, ObservableObject {
    var session = AVCaptureSession()
    var videoDeviceInput: AVCaptureDeviceInput!
    let output = AVCapturePhotoOutput()
    
    @Published var arr: [Data] = []
    @Published var recentImage: UIImage?
    
    // 카메라 셋업 과정을 담당하는 함수,
    func setUpCamera() {
        if let device = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                for: .video, position: .back) {
            do { // 카메라가 사용 가능하면 세션에 input과 output을 연결
                videoDeviceInput = try AVCaptureDeviceInput(device: device)
                if session.canAddInput(videoDeviceInput) {
                    session.addInput(videoDeviceInput)
                }
                
                if session.canAddOutput(output) {
                    session.addOutput(output)
//                    // 일단 필요없는 부분(추후 사용 가능)
//                    output.isHighResolutionCaptureEnabled = true
//                    output.maxPhotoQualityPrioritization = .quality
                }
                session.startRunning() // 세션 시작
            } catch {
                print(error) // 에러 프린트
            }
        }
    }
    
    func requestAndCheckPermissions() {
        // 카메라 권한 상태 확인
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // 권한 요청
            AVCaptureDevice.requestAccess(for: .video) { [weak self] authStatus in
                if authStatus {
                    DispatchQueue.main.async {
                        self?.setUpCamera()
                    }
                }
            }
        case .restricted:
            break
        case .authorized:
            // 이미 권한 받은 경우 셋업
            setUpCamera()
        default:
            // 거절했을 경우
            print("Permession declined")
        }
    }
    
    func capturePhoto() {
        // 사진 옵션 세팅
        let photoSettings = AVCapturePhotoSettings()
        
        // 캡처 해상도 및 비율을 1:1로 설정
        photoSettings.previewPhotoFormat = [
            kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA),
            kCVPixelBufferWidthKey as String: 1000,
            kCVPixelBufferHeightKey as String: 1000
        ]
        
        self.output.capturePhoto(with: photoSettings, delegate: self)
        print("[Camera]: Photo's taken")
    }
    
    // 화면 다시 촬영
    func retakePhoto(){
        DispatchQueue.global(qos: .background).async{
            self.session.startRunning()
        }
    }
    
    func changeCamera() {
        let currentPosition = self.videoDeviceInput.device.position // 현재 카메라 위치 가져오기
        let preferredPosition: AVCaptureDevice.Position // 선호하는 카메라 위치 변수 선언
        
        // 현재 카메라 위치에 따라 동작 결정
        switch currentPosition {
        // 위치가 명시되지 않았거나, 전면 카메라인 경우
        case .unspecified, .front:
            print("후면카메라로 전환합니다.")
            preferredPosition = .back // 선호하는 위치를 후면 카메라로 설정
            
        // 위치가 후면 카메라인 경우
        case .back:
            print("전면카메라로 전환합니다.")
            preferredPosition = .front // 선호하는 위치를 전면 카메라로 설정
            
        // 알 수 없는 경우
        @unknown default:
            print("알 수 없는 포지션. 후면카메라로 전환합니다.")
            preferredPosition = .back // 선호하는 위치를 후면 카메라로 설정
        }
        
        // 선호하는 카메라 위치로 AVCaptureDevice 인스턴스 가져오기
        if let videoDevice = AVCaptureDevice
            .default(.builtInWideAngleCamera,
                     for: .video, position: preferredPosition) {
            do {
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                self.session.beginConfiguration()
                
//                // 일단 필요없는 부분(추후 사용 가능)
//                if let inputs = session.inputs as? [AVCaptureDeviceInput] {
//                    for input in inputs {
//                        session.removeInput(input)
//                    }
//                }
//                if self.session.canAddInput(videoDeviceInput) {
//                    self.session.addInput(videoDeviceInput)
//                    self.videoDeviceInput = videoDeviceInput
//                } else {
//                    self.session.addInput(self.videoDeviceInput)
//                }
//                
//                if let connection =
//                    self.output.connection(with: .video) {
//                    if connection.isVideoStabilizationSupported {
//                        connection.preferredVideoStabilizationMode = .auto
//                    }
//                }
//                
//                output.isHighResolutionCaptureEnabled = true
//                output.maxPhotoQualityPrioritization = .quality
                
                self.session.commitConfiguration()
            } catch {
                print("Error occurred: \(error)")
            }
        }
    }
}

extension CameraManager: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation() else { return }
        
        if let image = UIImage(data: imageData) {
            self.recentImage = image // 최근 사진 반영
        }
        
        DispatchQueue.global(qos: .background).async{
            self.session.stopRunning() // 화면멈춤
        }
        
        print("[CameraModel]: Capture routine's done")
    }
}
