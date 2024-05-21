//
//  PartyService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

private enum NotificationTitle {
    static let shutdownWarningTitle = "10분뒤에 술자리가 종료됩니다."
    static let shutdownWarningSubTitle = "취했냐?ㅋㅋ 이번 Step에서 사진을 찍지 않으면, 10분뒤에 술자리가 종료되는 걸로 알겠습니당~ㅋ"
    
    static let shutdownTitle = "사진을 찍지 않아 술자리가 종료되었습니다."
    static let shutdownSubTitle = "취했네ㅋㅋㅋㅋㅌㅋ 포항항ꉂꉂ(ᵔᗜᵔ*)ㅋㅋㅋㅋ포항항항포핳핳항⚓⛴포항항ꉂꉂ(ᵔᗜᵔ*)ㅋㅋㅋㅋ"
    
    static let continuePartySubTitle = "사진을 찍어주세요!"
}

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
    
    /// Noti 알림 매니저
    private let notificationManager = NotificationManager.instance
}

// MARK: - Protocol Method
extension PartyService {
    
    func setPartyService(startDate: Date, notiCycle: NotiCycle) {
        self.startDate = startDate
        self.notiCycle = notiCycle
    }
    
    /// 술자리 처음 시작(혹은 재시작)
    func startParty(startDate: Date, notiCycle: NotiCycle) {
        
        print(#function)
        
        UserDefaults.standard.updatePartyLive(isLive: true)
        
        setPartyService(startDate: startDate, notiCycle: notiCycle)
        
        // PUSH 알림
        // 1. 강제 종료 10분전 예약 - 소리+배너
        notificationManager.scheduleNotification(date: currentShutdownWarningDate, title: NotificationTitle.shutdownWarningTitle, subtitle: NotificationTitle.shutdownWarningSubTitle)
        
        // 2. 강제 종료 되었을 때 예약 - 배너
        notificationManager.scheduleNotification(date: currentStepEndDate, title: NotificationTitle.shutdownTitle, subtitle: NotificationTitle.shutdownSubTitle)
        
    }
    
    /// 사진을 촬영했을 때(STEP을 완료했을 때)
    func stepComplete() {
        
        print(#function)
        
        // PUSH 알림
        // 1. 원래 예약 되어있었던 알림 모두 취소
        notificationManager.cancelNotification()
        
        // 2. 다음 STEP 알림을 예약 - 소리 + 배너
        notificationManager.scheduleNotification(date: currentStepEndDate, title: "STEP \(currentStep.intformatter)", subtitle: NotificationTitle.continuePartySubTitle)
        
        // 3. 다음 스텝 강제 종료 10분전 예약 - 소리+배너
        notificationManager.scheduleNotification(date: nextShutdownWarningDate, title: NotificationTitle.shutdownWarningTitle, subtitle: NotificationTitle.shutdownWarningSubTitle)
        
        // 4. 다음 스텝 강제 종료 되었을 때 예약 - 배너
        notificationManager.scheduleNotification(date: nextStepEndDate, title: NotificationTitle.shutdownTitle, subtitle: NotificationTitle.shutdownSubTitle)
    }
    
    /// 다음 STEP으로 넘어갔을 때
    func continueParty() {
        
        // 비동기 이벤트 예약
        // 1. 이번 STEP 종료 시간에 작동할 함수 실행(Notification)
    }
    
    /// STEP을 종료했을 때
    func endParty() {
        
        // PUSH 알림
        // 1. 원래 예약 되어있었던 알림 + 함수 모두 취소
        notificationManager.cancelNotification()
        notificationManager.cancelFunction()
        
        // 비동기 이벤트 예약
        // 1. 예약되어있던 함수 취소
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

// MARK: - 테스트용 STEP 계산
extension PartyService {
    
    /// 테스트용 술자리 시작 후 1분 뒤 날짜입니다.
    var testDate: Date {
        let testSecond = startDate.timeIntervalSince1970 + TimeInterval(10)
        return Date(timeIntervalSince1970: testSecond)
    }
}
