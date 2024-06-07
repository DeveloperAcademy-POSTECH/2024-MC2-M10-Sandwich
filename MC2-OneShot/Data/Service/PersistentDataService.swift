//
//  PersistentDataService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import Foundation
import SwiftData

// MARK: - PersistentDataService

struct PersistentDataService: PersistentDataServiceInterface {
    
    /// ModelContext
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
}

// MARK: - 프로토콜 구현체

extension PersistentDataService {
    
    /// 현재 파티가 라이브 중인지 확인합니다.
    func isPartyLive() -> Bool {
        return fetchPartys().lastParty?.isLive ?? false
    }
    
    /// 현재 진행 중인 STEP을 반환합니다.
    func currentStep() -> Step? {
        if let curreuntParty = fetchPartys().last,
           let curreuntStep = curreuntParty.stepList.sorted(by: {
               $0.createDate < $1.createDate
           }).last {
            return curreuntStep
        }
        
        return nil
    }
    
    /// Party 배열을 시작 날짜를 기준으로 정렬 후 반환합니다.
    func fetchPartys() -> [Party] {
        do {
            let fetchDescriptor = FetchDescriptor<Party>(sortBy: [.init(\.startDate)])
            return try modelContext.fetch(fetchDescriptor)
        } catch {
            print("Party 데이터 반환 실패")
            return []
        }
    }
    
    /// Party 데이터를 생성합니다.
    func createParty(_ party: Party) {
        modelContext.insert(party)
    }
    
    /// Party 데이터를 삭제합니다.
    func deleteParty(_ party: Party) {
        modelContext.delete(party)
    }
    
    /// Step 데이터를 삭제합니다.
    func deleteStep(_ step: Step) {
        modelContext.delete(step)
    }
    
    /// Step 사진을 저장합니다.
    func saveStepPhoto(_ photo: CapturePhoto) {
        guard let currentParty = fetchPartys().last else { return }
        let sortedSteps = currentParty.stepList.sorted { $0.createDate < $1.createDate }
        let newMedia = Media(fileData: photo.image.jpegData(compressionQuality: 1.0)!, captureDate: .now)
        sortedSteps.last?.mediaList.append(newMedia)
    }
    
    /// Member 사진을 저장합니다.
    func saveMemberPhoto(_ photo: CapturePhoto) -> Member {
        let newMember = Member(profileImageData: photo.image.jpegData(compressionQuality: 1.0)!)
        return newMember
    }
}

// MARK: - SwiftData Function

extension PersistentDataService {
    
    /// 현재 진행 중인 STEP 데이터를 반환합니다.
    private func currentSteps() -> [Step] {
        if let currentParty = fetchPartys().last {
            return currentParty.stepList
        } else {
            return []
        }
    }
}
