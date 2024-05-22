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
    func createParty(title: String, startDate: Date, notiCycle: NotiCycle) {
        let newParty = Party(
            title: title,
            startDate: startDate,
            notiCycle: notiCycle.rawValue
        )
        
        modelContext.insert(newParty)
    }
    
    /// 찍은 사진을 저장하는 데이터입니다.
    func saveMedia(step: Step, imageData: Data) {
        let newMedia = Media(fileData: imageData, captureDate: Date.now)
        step.mediaList.append(newMedia)
        
        try? modelContext.save()
    }
    
    /// StepList에 빈배열을 추가하는 데이터입니다.
    func addStep(party: Party) {
        // step 추가
        let newStep = Step(mediaList: [])
        party.stepList.append(newStep)
        
        try? modelContext.save()
    }
    
    /// 술자리 Party 데이터를 지울때 사용합니다.
    func deleteParty(_ party: Party) {
        modelContext.delete(party)
    }
}
