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
    
    func startParty()
    func stepComplete()
    func endParty()
}

struct StepManager: StepManagerProtocol {
    
    /// 술자리 시작 날짜
    let startDate: Date
    
    /// 알림 주기
    let notiCycle: NotiCycle
    
    /// 술자리 처음 시작
    func startParty() {
        // 1. 강제 종료 10분전 예약 - 소리+배너
        // 2. 강제 종료 되었을 때 예약 - 배너
    }
    
    /// 사진을 촬영했을 때(STEP을 완료했을 때)
    func stepComplete() {
        // 1. 원래 예약 되어있었던 알림 모두 취소
        // 2. 다음 STEP 알림을 예약 - 소리 + 배너
        // 3. 다음 스텝 강제 종료 10분전 예약 - 소리+배너
        // 4. 다음 스텝 강제 종료 되었을 때 예약 - 배너
    }
    
    /// STEP을 종료했을 때
    func endParty() {
        // 1. 원래 예약 되어있었던 알림 모두 취소
    }
}

// MARK: - 계산 속성
extension StepManager {
    
    /// 현재 스텝이 몇번째인지 반환하는 계산 속성
    var currentStep: Int {
        let durationTime = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
        return durationTime / notiCycle.toSeconds + 1
    }
    
    /// 현재 STEP의 강제 종료 시점 Date를 반환하는 계산 속성
    var currentShutdownDate: Date {
        let shutdownStepSecond = TimeInterval(currentStep * notiCycle.toSeconds)
        let shutdownSecond = startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 현재 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    var currentShutdownWarningDate: Date {
        let shutDownWarningSecond = currentShutdownDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
    
    /// 다음 STEP의 강제 종료 시점 Date를 반환하는 계산 속성
    var nextShutdownDate: Date {
        let shutdownStepSecond = TimeInterval((currentStep + 1) * notiCycle.toSeconds)
        let shutdownSecond = startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 다음 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    var nextShutdownWarningDate: Date {
        let shutDownWarningSecond = nextShutdownDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
}
