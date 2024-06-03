//
//  PartyPlayUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/3/24.
//

import Foundation

// MARK: - PartyPlay UseCase

@Observable
final class PartyPlayUseCase {
    
    private var dataService: PersistentDataServiceInterface
    
    private(set) var state: State
    
    init(dataService: PersistentDataServiceInterface) {
        self.dataService = dataService
        self.state = State()
    }
}

// MARK: - State Struct

extension PartyPlayUseCase {
    
    /// UseCase 상태 값
    struct State {
        var isPartyLive: Bool = false
    }
}

// MARK: - UseCase

extension PartyPlayUseCase {
    
    /// 파티를 시작합니다.
    func startParty(_ party: Party) {
        dataService.createParty(party)
        state.isPartyLive = true
    }
    
    /// 사진을 현재 스텝에 저장합니다.
    func savePhoto(_ photo: CapturePhoto) {
        dataService.savePhoto(photo)
    }
}
