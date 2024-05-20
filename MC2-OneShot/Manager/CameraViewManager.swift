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
    let cameraPreview: AnyView
    
    @Published var arr: [Data] = []
    @Published var recentImage: UIImage?
    
    // 초기 세팅
    func configure() {
        manager.requestAndCheckPermissions()
    }
    
    // 플래시 온오프
    func toggleFlash() {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
                guard device.hasTorch else { return }

                do {
                    try device.lockForConfiguration()
                    device.torchMode = device.isTorchActive ? .off : .on
                    device.unlockForConfiguration()
                } catch {
                    print("플래시를 제어할 수 없습니다: \(error)")
                }
//        if let device = AVCaptureDevice.default(for: .video), device.hasTorch {
//            do {
//                try device.lockForConfiguration()
//                try device.setTorchModeOn(level: 1.0) // 플래시 밝기(켜기)
//                
//                //3초후에 플래시 끄기 -> 3초후 꺼지는게 오히려 이질감이 들어서 그냥 일단 뺌
//                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
//                    device.unlockForConfiguration()
//                }
//                
//            } catch {
//                print("플래시를 제어할 수 없습니다: \(error)")
//            }
//        }
    }
    
    // 사진 촬영
    func capturePhoto() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2){
            self.manager.capturePhoto()
            print("찰칵")
        }
        print("[CameraViewModel]: Photo captured!")
    }
    
    // 다시 촬영
    func retakePhoto(){
        manager.retakePhoto()
        print("[CameraViewManager] : Photo retaker!")
    }
    
    // 전후면 카메라 스위칭
    func changeCamera() {
        manager.changeCamera()
        print("[CameraViewModel]: Camera changed!")
    }
    
    // 사진 저장(업로드)
    func cropImage() -> Data? {
        let croppedImage = cropImageToSquare(image: recentImage!)
        let imageData = croppedImage?.jpegData(compressionQuality: 1.0)
        
        return imageData
    }
    
    init() {
        manager = CameraManager.shared
        session = manager.session
        cameraPreview = AnyView(CameraPreviewView(session: session))
        
        manager.$recentImage
            .assign(to: &$recentImage)
    }
    
    // 이미지를 정사각형 모양으로 자르는 함수
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
