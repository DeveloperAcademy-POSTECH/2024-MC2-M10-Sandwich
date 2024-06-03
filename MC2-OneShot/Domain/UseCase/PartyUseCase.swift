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
    
    init(dataService: PersistentDataServiceInterface) {
        self.dataService = dataService
        self.state = State(partys: dataService.fetchPartys())
    }
}

// MARK: - State Struct

extension PartyUseCase {
    
    /// UseCase 상태 값
    struct State {
        var isPartyLive: Bool = false
        var partys: [Party]
    }
}

// MARK: - UseCase

extension PartyUseCase {
    
    /// 파티를 시작합니다.
    func startParty(_ party: Party) {
        dataService.createParty(party)
        state.isPartyLive = true
        state.partys = dataService.fetchPartys()
    }
    
    /// 사진을 현재 스텝에 저장합니다.
    func savePhoto(_ photo: CapturePhoto) {
        dataService.savePhoto(photo)
        state.partys = dataService.fetchPartys()
    }
}
