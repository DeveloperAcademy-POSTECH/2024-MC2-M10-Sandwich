//
//  Member.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import Foundation
import SwiftData

// MARK: - Member

@Model
class Member: Identifiable {
    let profileImageData: Data
    
    init(profileImageData: Data) {
        self.profileImageData = profileImageData
    }
}
