//
//  PartyCameraViewModel.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/17/24.
//

import AVFoundation
import SwiftUI
import Combine

// MARK: - PartyCameraViewModel

final class PartyCameraViewModel: ObservableObject {
    
    private let cameraService: PartyCameraService
    
    @Published var isCamera = true
    @Published var isBolt = false
    @Published var isFace = false
    @Published var isShotDisabled = false
    @Published var isPartyEnd = false
    @Published var isFinishPopupPresented = false
    
    @Published var cameraPreview: AnyView
    @Published var recentImage: UIImage?
    @Published var isShot = false
    @Published var isPhotoCaptureDone = false
    
    init() {
        cameraService = PartyCameraService()
        cameraPreview = AnyView(
            CameraPreviewView(session: cameraService.session)
        )
        
        cameraService.$recentImage
            .assign(to: &$recentImage)
        
        cameraService.$isPhotoCaptureDone
            .assign(to: &$isPhotoCaptureDone)
        
        configure()
    }
}

// MARK: - Camera Function

extension PartyCameraViewModel {
    
    // 초기 설정
    private func configure() {
        cameraService.requestAndCheckPermissions()
    }
    
    // 플래시 전환
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
    }
    
    // 사진 촬영
    func capturePhoto() {
        
        HapticManager.shared.impact(style: .light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.cameraService.capturePhoto()
            print("찰칵")
        }
        
        isShot = true
        
        print("CameraManager CapturePhoto 호출")
    }
    
    // 다시 촬영
    func retakePhoto() {
        cameraService.retakePhoto()
        isShot = false
        print("CameraManager retakePhoto 호출")
    }
    
    // 전후면 카메라 전환
    func changeCamera() {
        cameraService.changeCamera()
        print("CameraManager changeCamera 호출")
    }
    
    // 이미지를 정사각형으로 자르고 JPEG 데이터로 변환하여 반환
    func cropImage() -> Data? {
        guard let recentImage = recentImage else { return nil }
        let croppedImage = cropImageToSquare(image: recentImage)
        return croppedImage?.jpegData(compressionQuality: 1.0)
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
