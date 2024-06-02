//
//  PartyCameraUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import Foundation

// MARK: - PartyCamera Init

@Observable
final class PartyCameraUseCase {
    
    struct State {
        
    }
    
    var isBolt = false
    
    private var cameraService: PartyCameraService
    // private(set) var state: State
    
    init(
        cameraService: PartyCameraService
        // state: State
    ) {
        self.cameraService = cameraService
        // self.state = state
    }
}

// MARK: - UseCase Method

extension PartyCameraUseCase {
    
    func requestPermission() {
        cameraService.requestPermission()
        isBolt = false
    }
    
    /// 사진을 촬영합니다.
    func capturePhoto() {
        cameraService.capturePhoto()
    }
}
