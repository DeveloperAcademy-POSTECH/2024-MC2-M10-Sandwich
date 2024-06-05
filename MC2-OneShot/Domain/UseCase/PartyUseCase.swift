//
//  PartyUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/3/24.
//

import Foundation

// MARK: - Party UseCase

@Observable
final class PartyUseCase {
    
    private var dataService: PersistentDataServiceInterface
    
    private(set) var state: State
    private(set) var partys: [Party]
    
    init(dataService: PersistentDataServiceInterface) {
        self.dataService = dataService
        self.state = State(isPartyLive: dataService.isPartyLive())
        self.partys = dataService.fetchPartys()
    }
}

// MARK: - State Struct

extension PartyUseCase {
    
    /// UseCase 상태 값
    @Observable
    final class State {
        var isPartyLive: Bool
        var isCameraViewPresented: Bool
        var isResultViewPresented: Bool
        
        init(isPartyLive: Bool) {
            self.isPartyLive = isPartyLive
            self.isCameraViewPresented = false
            self.isResultViewPresented = false
        }
    }
}

// MARK: - UseCase

extension PartyUseCase {
    
    /// 파티를 시작합니다.
    func startParty(_ party: Party) {
        dataService.createParty(party)
        state.isPartyLive = true
        state.isCameraViewPresented = true
        partys = dataService.fetchPartys()
    }
    
    /// 사진을 현재 스텝에 저장합니다.
    func savePhoto(_ photo: CapturePhoto) {
        dataService.savePhoto(photo)
        partys = dataService.fetchPartys()
    }
    
    /// 파티를 종료합니다.
    func finishParty() {
        state.isResultViewPresented = true
        state.isPartyLive = false
    }
}

// MARK: - Presentaion

extension PartyUseCase {
    
    /// CameraView를 컨트롤합니다.
    func presentCameraView(to bool: Bool) {
        state.isCameraViewPresented = bool
    }
    
    /// ResultView를 컨트롤합니다.
    func presentResultView(to bool: Bool) {
        state.isResultViewPresented = bool
    }
}
