//
//  CameraUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import SwiftUI
import Combine

// MARK: - Camera Init

@Observable
final class CameraUseCase {
    
    private var cameraService: CameraServiceInterface
    
    private(set) var state: State
    
    private var cancellable = [AnyCancellable]()
    
    init(cameraService: CameraServiceInterface) {
        self.cameraService = cameraService
        self.state = State()
        self.sink()
    }
}

// MARK: - Combine

extension CameraUseCase {
    
    /// Publisher를 연결합니다.
    private func sink() {
        cameraService.orientationChange()
            .assign(to: \.state.orientation, on: self)
            .store(in: &cancellable)
        
        cameraService.orientationChange()
            .sink {
                self.state.rotation =
                self.cameraService.rotationAngle(orientation: $0)
            }
            .store(in: &cancellable)
    }
}

// MARK: - State Struct

extension CameraUseCase {
    
    /// UseCase 상태 값
    struct State {
        var isCaptureMode: Bool = true
        var isFlashMode: Bool = false
        var isSelfieMode: Bool = false
        var isPhotoDataPrepare: Bool = false
        var photoData: CapturePhoto?
        var currentZoomFactor: CGFloat = 1.0
        var lastScale: CGFloat = 1.0
        var rotation: Angle = .degrees(0)
        var orientation: UIDeviceOrientation = .portrait
    }
}

// MARK: - Camera UseCase Method

extension CameraUseCase {
    
    /// 카메라 Preview 객체를 반환합니다.
    var preview: AnyView {
        return cameraService.displayPreview()
    }
    
    /// 카메라 권한을 요청합니다.
    func requestPermission() {
        cameraService.requestPermission()
    }
    
    /// 사진을 촬영합니다.
    func capturePhoto() {
        cameraService.capturePhoto { [weak self] photo in
            self?.state.photoData = photo
            self?.state.isPhotoDataPrepare = true
        }
        
        state.isCaptureMode.toggle()
        
        if state.isFlashMode && !state.isSelfieMode {
            cameraService.toggleFlashMode()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                [weak self] in
                self?.cameraService.toggleFlashMode()
            }
        }
    }
    
    /// 사진을 다시 촬영합니다.
    func retakePhoto() {
        state.isCaptureMode = true
        state.isPhotoDataPrepare = false
    }
    
    /// 방금 촬영한 사진을 반환합니다.
    func fetchPhotoForSave() -> CapturePhoto? {
        guard let photoData = cameraService.fetchPhotoDataForSave()
        else {
            print("사진 데이터 누락 저장 실패")
            return nil
        }
        
        return photoData
    }
    
    /// 플래시 모드를 토글합니다.
    func toggleFlashMode() {
        state.isFlashMode.toggle()
    }
    
    /// 전면 / 후면 카메라를 전환합니다.
    func toggleFrontBack() {
        cameraService.toggleFrontBack()
        state.isSelfieMode.toggle()
    }
    
    /// 일반 줌 배열 모드로 전환합니다.
    func generalAngle() {
        cameraService.generalAngle()
    }
    
    /// 광각 모드를 전환합니다.
    func wideAngle() {
        cameraService.wideAngle()
    }
    
    /// 줌 배율을 조절합니다.
    func zoom(factor: CGFloat) {
        let delta = factor / state.lastScale
        state.lastScale = factor
    
        state.currentZoomFactor = cameraService.zoom(
            currentZoomFactor: state.currentZoomFactor,
            delta: delta
        )
    }
    
    /// 줌 배율을 초기화합니다.
    func zoomInitialize() {
        state.lastScale = 1.0
    }
    
}
