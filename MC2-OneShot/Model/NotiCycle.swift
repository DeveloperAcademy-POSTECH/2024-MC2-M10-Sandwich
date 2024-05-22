//
//  NotiCycle.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

enum NotiCycle: Int {
    case min30 = 1
    case min60 = 60
    case min90 = 90
    case min120 = 120
    
    /// NotiCycle을 초 단위로 변환하는 계산 속성
    var toSeconds: Int {
        return self.rawValue * 60
    }
}
