//
//  Party.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/16/24.
//

import UIKit

typealias Party = OneShotSchemaV2.Party

// MARK: - Party 계산 속성

extension Party {
    
    /// StepList를 정렬 후 반환합니다.
    var sortedStepList: [Step] {
        return stepList.sorted { $0.createDate < $1.createDate }
    }
    
    /// MemberList를 정렬 후 반환합니다.
    var sortedMemberList: [Member] {
        return memberList.sorted { $0.captureDate < $1.captureDate }
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
