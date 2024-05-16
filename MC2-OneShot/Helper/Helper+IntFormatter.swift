//
//  Helper+IntFormatter.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/16/24.
//

import Foundation
import SwiftUI

extension View {
    // 숫자 형식을 9를 09로 반환합니다.
    func intformatter(_ num : Int) -> String {
        let str = String(format: "%02d", num)
        
        return str
    }
}
