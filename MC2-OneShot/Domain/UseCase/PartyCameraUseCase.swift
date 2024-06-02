//
//  PartyCameraUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import SwiftUI

// MARK: - PartyCamera Init

@Observable
final class PartyCameraUseCase {
    
    private var cameraService: PartyCameraInterface
    private var dataService: PersistentDataService
    
    private(set) var state: State
    
    init(cameraService: PartyCameraInterface, dataService: PersistentDataService) {
        self.cameraService = cameraService
        self.dataService = dataService
        self.state = State()
    }
}

// MARK: - State Struct

extension PartyCameraUseCase {
    
    struct State {
        var isCaptureMode: Bool = true
        var isFlashMode: Bool = false
        var isSelfieMode: Bool = false
    }
}

// MARK: - UseCase Method

extension PartyCameraUseCase {
    
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
        if state.isCaptureMode {
            cameraService.capturePhoto()
            state.isCaptureMode.toggle()
            
            if state.isFlashMode && !state.isSelfieMode {
                cameraService.toggleFlashMode()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.cameraService.toggleFlashMode()
                }
            }
        }
    }
    
    /// 사진을 저장합니다.
    func savePhoto() {
        guard let photoData = cameraService.fetchPhotoDataForSave() else {
            print("사진 데이터 누락 저장 실패")
            return
        }
        dataService.savePhoto(data: photoData)
        state.isCaptureMode.toggle()
    }
    
    /// 플래시 모드를 토글합니다.
    func toggleFlashMode() {
        state.isFlashMode.toggle()
    }
}
