//
//  Step.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import Foundation
import SwiftData

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
