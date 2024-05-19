//
//  PersistentDataManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/18/24.
//

import Foundation
import SwiftUI
import SwiftData

final class PersistentDataManager: ObservableObject {
    
    /// ModelContext
    var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - PartySetView Method
extension PersistentDataManager {
    
    /// 술자리를 시작할 때 생성하는 Party 데이터입니다.
    func createParty(title: String, notiCycle: NotiCycle) {
        let newParty = Party(
            title: title,
            startDate: Date(),
            notiCycle: notiCycle.rawValue
        )
        
        modelContext.insert(newParty)
    }
    
    /// 찍은 사진을 해당 스텝에 저장합니다.
    
}
