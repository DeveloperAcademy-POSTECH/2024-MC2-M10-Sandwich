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
    
    /// 2024년 5월 13일 (월) 형식의 문자열을 반환합니다.
    var yearMonthdayweekDay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: self)
    }
    
    /// 18:03 형식의 문자열을 반환합니다.
    var hourMinute: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
}
