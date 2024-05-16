//
//  OneShotData.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/14/24.
//

import Foundation
// import SwiftData

// @Model
class Party: Identifiable {
    let id: UUID = .init()
    
    let title: String
    let startDate: Date
    let notiCycle: Int
    var stepList: [Step]
    
    var isLive: Bool
    var isShutdown: Bool
    
    let memberList: [Member]?
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

class Step: Identifiable {
    var mediaList: [Media]
    
    init(mediaList: [Media]) {
        self.mediaList = mediaList
    }
}

class Media {
    var fileData: String // TODO: 어떤 타입이 들어갈 수 있는지 리서치
    var captureDate: Date
    
    init(fileData: String, captureDate: Date) {
        self.fileData = fileData
        self.captureDate = captureDate
    }
}

class Member: Identifiable {
    let profileImage: String // TODO: 어떤 타입이 들어갈 수 있는지 리서치
    
    init(profileImage: String) {
        self.profileImage = profileImage
    }
}
