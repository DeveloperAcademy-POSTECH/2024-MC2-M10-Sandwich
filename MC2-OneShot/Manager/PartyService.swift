//
//  PartyManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

protocol PartyServiceProtocol {
    func startParty(startDate: Date, notiCycle: NotiCycle)
    func stepComplete()
    func continueParty()
    func endParty()
}

final class PartyService: PartyServiceProtocol {
    
    static let shared = PartyService()
    private init() {}
    
    /// 술자리 시작 날짜
    private var startDate: Date = .now
    
    /// 알림 주기
    private var notiCycle: NotiCycle = .min30
}

// MARK: - Protocol Method
extension PartyService {
    
    /// 술자리 처음 시작(혹은 재시작)
    func startParty(startDate: Date, notiCycle: NotiCycle) {
        
        self.startDate = startDate
        self.notiCycle = notiCycle
        
        // PUSH 알림
        // 1. 강제 종료 10분전 예약 - 소리+배너
        // 2. 강제 종료 되었을 때 예약 - 배너
        
        // 타이머
        // 1. 이번 STEP 종료 시간에 작동할 타이머 실행
        
        // 사진 저장
        //
    }
    
    /// 사진을 촬영했을 때(STEP을 완료했을 때)
    func stepComplete() {
        
        // PUSH 알림
        // 1. 원래 예약 되어있었던 알림 모두 취소
        // 2. 다음 STEP 알림을 예약 - 소리 + 배너
        // 3. 다음 스텝 강제 종료 10분전 예약 - 소리+배너
        // 4. 다음 스텝 강제 종료 되었을 때 예약 - 배너
    }
    
    /// 다음 STEP으로 넘어갔을 때
    func continueParty() {
        
        // 타이머
        // 1. 이번 STEP 종료 시간에 작동할 타이머 실행
    }
    
    /// STEP을 종료했을 때
    func endParty() {
        
        // PUSH 알림
        // 1. 원래 예약 되어있었던 알림 모두 취소
        
        // 타이머
        // 1. 돌아가던 타이머 취소
    }
}

// MARK: - 현재 STEP 계산
extension PartyService {
    
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
extension PartyService {
    
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
