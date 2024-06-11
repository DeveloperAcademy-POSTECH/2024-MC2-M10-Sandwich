//
//  NotiCycle.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

/// 술자리 STEP 알림 주기 열거형
enum NotiCycle: Int, CaseIterable {
    
    #if DEBUG
    case min01 = 1
    #endif
    
    case min30 = 30
    case min60 = 60
    case min90 = 90
    case min120 = 120
    
    /// NotiCycle을 초 단위로 변환하는 계산 속성
    var toSeconds: Int {
        return self.rawValue * 30
    }
}
