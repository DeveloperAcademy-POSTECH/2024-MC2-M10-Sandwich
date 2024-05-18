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

// MARK: - Method
extension PersistentDataManager {
    
    func createParty(title: String, notiCycle: NotiCycle) {
        let newParty = Party(
            title: title,
            startDate: Date(),
            notiCycle: notiCycle.rawValue
        )
        
        modelContext.insert(newParty)
        try? modelContext.save()
    }
}
