//
//  Party.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import Foundation
import UIKit
import SwiftData

// MARK: - Party

@Model
class Party: Identifiable {
    @Attribute(.unique) let id: UUID
    
    let title: String
    let startDate: Date
    let notiCycle: Int
    @Relationship(deleteRule: .cascade) var stepList: [Step]
    
    var isLive: Bool
    var isShutdown: Bool
    
    @Relationship(deleteRule: .cascade) var memberList: [Member]
    var comment: String?
    
    init(
        title: String,
        startDate: Date,
        notiCycle: Int,
        stepList: [Step] = [Step()],
        isLive: Bool = true,
        isShutdown: Bool = false,
        memberList: [Member],
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

// MARK: - Party 계산 속성

extension Party {
    
    /// StepList를 정렬 후 반환합니다.
    var sortedStepList: [Step] {
        return stepList.sorted { $0.createDate < $1.createDate }
    }
    
    /// 리스트에 보여질 첫번째 썸네일 데이터를 반환합니다.
    var firstThumbnailData: UIImage {
        let firstMedia = sortedStepList
            .first?.mediaList
            .sorted { $0.captureDate < $1.captureDate }
            .first
        
        if let fileData = firstMedia?.fileData,
           let image = UIImage(data: fileData) {
            return image
        } else {
            return UIImage(resource: .noImageSign)
        }
    }
    
    /// 파티를 진행한 전체 시간 문자열을 반환합니다.
    var totalTime: String {
        let startTime = self.startDate.hourMinute
        let stepCount = self.stepList.count
        let allSteptime = (stepCount + 1) * self.notiCycle
        
        // 1. 자동 종료된 경우
        if self.isShutdown {
            let finishTime = Date(
                timeInterval: TimeInterval(allSteptime * 60),
                since: self.startDate
            ).hourMinute
            return "\(startTime) ~ \(finishTime)"
        }
        
        // 2. 직접 종료한 경우
        else {
            let finishTime = Date().hourMinute
            return "\(startTime) ~ \(finishTime)"
        }
    }
}


// MARK: - [Party] 계산 속성

extension [Party] {
    
    /// 날짜를 기준으로 정렬한 Party 배열을 반환합니다.
    var sortedPartys: [Party] {
        return self.sorted { $0.startDate < $1.startDate }
    }
    
    /// 마지막(현재 진행 중인) 파티를 반환합니다.
    var lastParty: Party? {
        return sortedPartys.last
    }
    
    /// 마지막(현재 진행 중인) 파티가 진행 중인 여부를 반환합니다.
    var isLastParyLive: Bool {
        if let party = lastParty { return party.isLive }
        return false
    }
}
