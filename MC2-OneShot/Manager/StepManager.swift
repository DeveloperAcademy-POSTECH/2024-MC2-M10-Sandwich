//
//  StepManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

protocol StepManagerProtocol {
    
    /// 술자리 시작 날짜
    var startDate: Date { get set }
    
    /// 알림 주기
    var notiCycle: NotiCycle { get }
    
    /// 술자리 처음 시작
    func startParty()
    
    /// 사진을 촬영했을 때(STEP을 완료했을 때)
    func stepComplete()
    
    /// STEP을 종료했을 때
    func endParty()
}

struct StepManager: StepManagerProtocol {
    
    /// 술자리 시작 날짜
    var startDate: Date
    
    /// 알림 주기
    let notiCycle: NotiCycle
    
    func startParty() {
        // 1. 강제 종료 10분전 예약 - 소리+배너
        // 2. 강제 종료 되었을 때 예약 - 배너
    }
    
    func stepComplete() {
        // 1. 원래 예약 되어있었던 알림 모두 취소
        // 2. 다음 STEP 알림을 예약 - 소리 + 배너
        // 1. 다음 스텝 강제 종료 10분전 예약 - 소리+배너
        // 2. 다음 스텝 강제 종료 되었을 때 예약 - 배너
    }
    
    func endParty() {
        // 1. 원래 예약 되어있었던 알림 모두 취소
    }
}

extension StepManager {
    
    /// 현재 스텝이 몇번째인지 반환하는 계산 속성
    var currentStep: Int {
        
        // 1. 술자리 시작 후 지난 시간 = 현재 시간 - 술자리 시작 시간
        let durationTime = Int(Date().timeIntervalSince1970 - startDate.timeIntervalSince1970)
        
        // 2. currentStep = (지난 시간 / NotiCycle) + 1
        return durationTime / (notiCycle.rawValue * 60) + 1
    }
}
