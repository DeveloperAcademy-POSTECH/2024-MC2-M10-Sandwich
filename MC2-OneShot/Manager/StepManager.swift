//
//  StepManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

protocol StepManagerProtocol {
    var startDate: Date { get }
    var notiCycle: NotiCycle { get }
}

struct StepManager: StepManagerProtocol {
    
    /// 술자리 시작 날짜
    let startDate: Date
    
    /// 알림 주기
    let notiCycle: NotiCycle
}

// MARK: - 현재 STEP 계산
extension StepManager {
    
    /// 현재 스텝이 몇번째인지 반환하는 계산 속성
    var currentStep: Int {
        let durationTime = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
        return durationTime / notiCycle.toSeconds + 1
    }
    
    /// 현재 STEP의 마지막 시점 Date를 반환하는 계산 속성
    var currentStepEndDate: Date {
        let shutdownStepSecond = TimeInterval(currentStep * notiCycle.toSeconds)
        let shutdownSecond = startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 현재 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    var currentShutdownWarningDate: Date {
        let shutDownWarningSecond = currentStepEndDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
}

// MARK: - 다음 STEP 계산
extension StepManager {
    
    /// 다음 STEP의 마지막 시점 Date를 반환하는 계산 속성
    var nextStepEndDate: Date {
        let shutdownStepSecond = TimeInterval((currentStep + 1) * notiCycle.toSeconds)
        let shutdownSecond = startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 다음 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    var nextShutdownWarningDate: Date {
        let shutDownWarningSecond = nextStepEndDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
}