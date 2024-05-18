//
//  OneShotData.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/14/24.
//

import Foundation
import SwiftData

@Model
class Party: Identifiable {
    let id: UUID
    
    let title: String
    let startDate: Date
    let notiCycle: Int
    @Relationship(deleteRule: .cascade) var stepList: [Step]
    
    var isLive: Bool
    var isShutdown: Bool
    
    @Relationship(deleteRule: .cascade) let memberList: [Member]?
    var comment: String?
    
    init(
        title: String,
        startDate: Date,
        notiCycle: Int,
        stepList: [Step] = [],
        isLive: Bool = true,
        isShutdown: Bool = false,
        memberList: [Member]? = nil,
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

@Model
class Step: Identifiable {
    @Relationship(deleteRule: .cascade) var mediaList: [Media]
    
    init(mediaList: [Media]) {
        self.mediaList = mediaList
    }
}

@Model
class Media {
    var fileData: Data
    var captureDate: Date
    
    init(fileData: Data, captureDate: Date) {
        self.fileData = fileData
        self.captureDate = captureDate
    }
}

@Model
class Member: Identifiable {
    let profileImageData: Data
    
    init(profileImageData: Data) {
        self.profileImageData = profileImageData
    }
}
