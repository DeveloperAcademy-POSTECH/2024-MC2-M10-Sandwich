//
//  OneShotData.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/14/24.
//

import Foundation
import SwiftData

// MARK: - Party
@Model
class Party: Identifiable {
    @Attribute(.unique) let id: UUID
    
    let title: String
    let startDate: Date
    let notiCycle: Int
    @Relationship(deleteRule: .cascade) var stepList: [Step]
    
    var isLive: Bool
    var isShutdown: Bool
    
    @Relationship(deleteRule: .cascade) var memberList: [Member]
    var comment: String?
    
    /// StepList를 정렬 후 마지막 Step을 반환합니다.
    var lastStep: Step? {
        return stepList.sorted { $0.createDate < $1.createDate }.last
    }
    
    init(
        title: String,
        startDate: Date,
        notiCycle: Int,
        stepList: [Step] = [Step()],
        isLive: Bool = true,
        isShutdown: Bool = false,
        memberList: [Member],
        comment: String? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.startDate = startDate
        self.notiCycle = notiCycle
        self.stepList = stepList
        self.isLive = isLive
        self.isShutdown = isShutdown
        self.memberList = memberList
        self.comment = comment
    }
}

// MARK: - Step
@Model
class Step: Identifiable {
    
    let createDate: Date
    @Relationship(deleteRule: .cascade) var mediaList: [Media]
    
    init(createDate: Date = .now, mediaList: [Media] = []) {
        self.createDate = createDate
        self.mediaList = mediaList
    }
}

// MARK: - Media
@Model
class Media: Identifiable {
    var fileData: Data
    var captureDate: Date
    
    init(fileData: Data, captureDate: Date) {
        self.fileData = fileData
        self.captureDate = captureDate
    }
}

// MARK: - Member
@Model
class Member: Identifiable {
    let profileImageData: Data
    
    init(profileImageData: Data) {
        self.profileImageData = profileImageData
    }
}

// MARK: - [Party]
extension [Party] {
    
    /// 마지막(현재 진행 중인) 파티를 반환합니다.
    var lastParty: Party? {
        let sortedParty = self.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
}
