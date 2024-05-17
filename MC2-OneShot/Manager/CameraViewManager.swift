//
//  CameraViewManager.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//

import SwiftUI
import AVFoundation
import Combine

class CameraViewManager: ObservableObject {
    private let manager: CameraManager
    private let session: AVCaptureSession
    private var subscriptions = Set<AnyCancellable>() // 추가
    let cameraPreview: AnyView

    @Published var recentImage: UIImage? // 추가
    @Published var isSilentModeOn = false
    
    // 초기 세팅
    func configure() {
        manager.requestAndCheckPermissions()
    }
    
    
    // 플래시 온오프
    func toggleFlash() {
        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
            do {
                try device.lockForConfiguration()
                try device.setTorchModeOn(level: 1.0) // 플래시 켜기
                
                //3초후에 플래시 끄기
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    device.unlockForConfiguration()
                }
                
            } catch {
                print("플래시를 제어할 수 없습니다: \(error)")
            }
        }
    }
    
    

    
    // 사진 촬영
    func capturePhoto() {
        manager.capturePhoto()
        print("[CameraViewModel]: Photo captured!")
    }
    
    func retakePhoto(){
        manager.retakePhoto()
        print("[CameraViewManager] : Photo retaker!")
    }
    
    
    // 전후면 카메라 스위칭
    func changeCamera() {
        manager.changeCamera()
        print("[CameraViewModel]: Camera changed!")
    }
    
    init() {
        manager = CameraManager()
        session = manager.session
        cameraPreview = AnyView(CameraPreviewView(session: session))
        
        manager.$recentImage.sink { [weak self] (photo) in // 추가
            guard let pic = photo else { return }
            // 이미지를 정사각형 모양으로 가져옴
            if let croppedImage = self?.cropImageToSquare(image: pic) {
                self?.recentImage = croppedImage
            }
        }
        .store(in: &self.subscriptions)
    }
    
    // 이미지를 정사각형 모양으로 자르는 함수
    private func cropImageToSquare(image: UIImage) -> UIImage {
        let cgImage = image.cgImage!
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        let aspectRatio = width / height
        var rect = CGRect.zero
        
        if aspectRatio > 1 { // 가로가 더 긴 경우
            rect = CGRect(x: (width - height) / 2, y: 0, width: height, height: height)
        } else { // 세로가 더 긴 경우
            rect = CGRect(x: 0, y: (height - width) / 2, width: width, height: width)
        }
        
        if let croppedCGImage = cgImage.cropping(to: rect) {
            return UIImage(cgImage: croppedCGImage, scale: image.scale, orientation: image.imageOrientation)
        }
        
        return image
    }
}
