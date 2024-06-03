//
//  PartyCameraUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import SwiftUI

// MARK: - PartyCamera Init

@Observable
final class PartyCameraUseCase: ObservableObject {
    
    private var cameraService: PartyCameraServiceInterface
    private var dataService: PersistentDataServiceInterface
    
    private(set) var state: State
    
    init(
        cameraService: PartyCameraServiceInterface,
        dataService: PersistentDataServiceInterface
    ) {
        self.cameraService = cameraService
        self.dataService = dataService
        self.state = State()
    }
}

// MARK: - State Struct

extension PartyCameraUseCase {
    
    /// UseCase 상태 값
    struct State {
        var isCaptureMode: Bool = true
        var isFlashMode: Bool = false
        var isSelfieMode: Bool = false
        var isPhotoDataPrepare: Bool = false
        var photoData: CapturePhoto?
        var isFinishPopupPresented: Bool = false
        var isPartyFinish: Bool = false
    }
}

// MARK: - Camera UseCase Method

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
            cameraService.capturePhoto { [weak self] photo in
                self?.state.photoData = photo
                self?.state.isPhotoDataPrepare = true
            }
            
            state.isCaptureMode.toggle()
            
            if state.isFlashMode && !state.isSelfieMode {
                cameraService.toggleFlashMode()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                    self?.cameraService.toggleFlashMode()
                }
            }
        }
    }
    
    /// 사진을 다시 촬영합니다.
    func retakePhoto() {
        state.isCaptureMode = true
        state.isPhotoDataPrepare = false
    }
    
    /// 사진을 저장합니다.
    func savePhoto() {
        guard let photoData = cameraService.fetchPhotoDataForSave() else {
            print("사진 데이터 누락 저장 실패")
            return
        }
        dataService.savePhoto(photoData)
        state.isCaptureMode = true
        state.isPhotoDataPrepare = false
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
    
    /// 술자리 파티를 종료합니다.
    func finishParty() {
        state.isPartyFinish = true
    }
}

// MARK: - List Use Case

extension PartyCameraUseCase {
    
    /// Party 배열을 반환합니다.
    func fetchPartys() -> [Party] {
        return dataService.fetchPartys()
    }
    
    /// 현재 진행 중인 STEP 배열을 반환합니다.
    func currentSteps() -> [Step] {
        return dataService.currentSteps()
    }
}
