//
//  Helper+DateFormatter.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/15/24.
//

import Foundation

extension Date {
    
    /// 2024. 05. 15 형식의 문자열을 반환합니다.
    var yearMonthDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd"
        return formatter.string(from: self)
    }
}
