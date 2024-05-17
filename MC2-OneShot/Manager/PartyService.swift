//
//  PartyManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation

protocol PartyServiceProtocol {
    func startParty()
    func stepComplete()
    func continueParty()
    func endParty()
}

struct PartyService: PartyServiceProtocol {
    
    /// 술자리 처음 시작(혹은 재시작)
    func startParty() {
        
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
