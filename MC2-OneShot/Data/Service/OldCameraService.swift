//
//  OldCameraService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/3/24.
//

import UIKit
import AVFoundation

class OldPartyCameraService: NSObject, ObservableObject {
    
    var session = AVCaptureSession()
    private var videoDeviceInput: AVCaptureDeviceInput!
    private let output = AVCapturePhotoOutput()
    
    @Published var recentImage: UIImage?
    @Published var isPhotoCaptureDone = false
    
    private let sessionQueue = DispatchQueue(label: "session queue")
    
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
