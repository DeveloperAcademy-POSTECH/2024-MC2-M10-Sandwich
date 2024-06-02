//
//  PersistentDataService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import Foundation
import SwiftData

// MARK: - PersistentDataService

struct PersistentDataService: PersistentDataInterface {
    
    /// ModelContext
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - 프로토콜 구현체

extension PersistentDataService {
    
    /// 사진을 저장합니다.
    func savePhoto(data: Data) {
        let sortedSteps = fetchPartys().lastParty!.stepList.sorted { $0.createDate < $1.createDate }
        let newMedia = Media(fileData: data, captureDate: .now)
        sortedSteps.last?.mediaList.append(newMedia)
    }
}

// MARK: - SwiftData Function

extension PersistentDataService {
    
    private func fetchPartys() -> [Party] {
        do {
            let fetchDescriptor = FetchDescriptor<Party>()
            return try modelContext.fetch(fetchDescriptor)
        } catch {
           print("Party 데이터 반환 실패")
            return []
        }
    }
}
