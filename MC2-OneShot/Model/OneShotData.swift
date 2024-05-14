//
//  OneShotData.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/14/24.
//

import Foundation
// import SwiftData

// @Model
struct Party {
    let id: UUID = .init()
    
    let title: String
    let startDate: Date
    let notiCycle: Int
    var stepList: [Step] = []
    
    var isLive: Bool = true
    var isShutdown: Bool = false
    
    let memberList: [Member]?
    var comment: String?
}

struct Step {
    var mediaList: [Media]
}

struct Media {
    var fileData: String // TODO: 어떤 타입이 들어갈 수 있는지 리서치
    var captureDate: Date
}

struct Member {
    let profileImage: String // TODO: 어떤 타입이 들어갈 수 있는지 리서치
}
