//
//  PartyUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/3/24.
//

import Foundation

// MARK: - Party UseCase

@Observable
final class PartyUseCase {
    
    private var dataService: PersistentDataServiceInterface
    private var notificationService: NotificationServiceInterface
    
    private(set) var state: State
    private(set) var partys: [Party]
    
    init(
        dataService: PersistentDataServiceInterface,
        notificationService: NotificationServiceInterface
    ) {
        let partys = dataService.fetchPartys()
        let startDate = partys.last?.startDate ?? .now
        let notiCycle = NotiCycle(
            rawValue: partys.last?.notiCycle ?? 30
        ) ?? .min30
        
        self.dataService = dataService
        self.notificationService = notificationService
        self.state = State(
            startDate: startDate,
            notiCycle: notiCycle,
            isPartyLive: dataService.isPartyLive()
        )
        
        self.partys = partys
    }
}

// MARK: - State Struct

extension PartyUseCase {
    
    /// UseCase 상태 값
    @Observable
    final class State {
        var startDate: Date
        var notiCycle: NotiCycle
        
        var isPartyLive: Bool
        var isCameraViewPresented: Bool
        var isResultViewPresented: Bool
        
        init(
            startDate: Date,
            notiCycle: NotiCycle,
            isPartyLive: Bool
        ) {
            self.startDate = startDate
            self.notiCycle = notiCycle
            self.isPartyLive = isPartyLive
            self.isCameraViewPresented = false
            self.isResultViewPresented = false
        }
    }
}

// MARK: - UseCase

extension PartyUseCase {
    
    /// 앱 실행 시 파티 로직에 필요한 초기 설정을 진행합니다.
    func initialSetup() {
        notificationService.requestPermission()
        notificationService.resetBadge()
        
        if state.isPartyLive {
            if let lastParty = partys.last,
               let lastStep = dataService.currentStep() {
                lastStep.mediaList.isEmpty ?
                whenLastStepNotComplete(lastParty: lastParty) :
                whenLastStepComplete(lastParty: lastParty)
            }
        }
    }
    
    /// 파티를 시작합니다.
    func startParty(_ party: Party) {
        dataService.createParty(party)
        state.isPartyLive = true
        state.startDate = party.startDate
        state.notiCycle = NotiCycle(rawValue: party.notiCycle) ?? .min30
        state.isCameraViewPresented = true
        partys = dataService.fetchPartys()
    }
    
    /// 사진을 현재 스텝에 저장합니다.
    func savePhoto(_ photo: CapturePhoto) {
        dataService.savePhoto(photo)
        partys = dataService.fetchPartys()
    }
    
    /// 파티를 종료합니다.
    func finishParty() {
        guard let currentParty = partys.last else { return }
        currentParty.isLive = false
        state.isResultViewPresented = true
        state.isPartyLive = false
    }
}

// MARK: - Helper

extension PartyUseCase {
    
    /// Step이 완료되지 않았을 때 실행되는 로직
    private func whenLastStepNotComplete(lastParty: Party) {
        let presentTime = Date.now.timeIntervalSince1970
        let stepCount = lastParty.stepList.count
        let stepTime = state.notiCycle.toSeconds
        let shutdownTime = TimeInterval(stepCount * stepTime)
        let endTime = state.startDate.timeIntervalSince1970 + shutdownTime
        let endDate = Date(timeIntervalSince1970: endTime)
        let restTime = endTime - presentTime
        
        // 현재Step마지막 - 현재시간 > 0 : 초과 아닐 때
        if restTime > 0 {
            notificationService.scheduleFunction(date: endDate) {
                [weak self] in
                self?.finishParty()
                lastParty.isShutdown = true
            }
            
            state.isCameraViewPresented = true
        }
        
        // 현재Step마지막 - 현재시간 > 0 : 초과일 때
        else {
            finishParty()
            lastParty.isShutdown = true
        }
    }
    
    /// STEP을 완료했을 때 실행되는 로직
    private func whenLastStepComplete(lastParty: Party) {
        let presentTime = Date.now.timeIntervalSince1970
        let stepCount = lastParty.stepList.count
        let stepTime = state.notiCycle.toSeconds
        let shutdownTime = TimeInterval((stepCount + 1) * stepTime)
        let startDateTime = state.startDate.timeIntervalSince1970
        let nextStepEndTime = startDateTime + shutdownTime
        let nextStepEndDate = Date(timeIntervalSince1970: nextStepEndTime)
        let nextStepStartTime = startDateTime + TimeInterval(stepCount * stepTime)
        let nextStepStartDate = Date(timeIntervalSince1970: nextStepStartTime)
        let restTime = nextStepEndTime - presentTime
        
        if restTime > 0 {
            NotificationManager.instance.scheduleFunction(date: nextStepEndDate) {
                [weak self] in
                self?.finishParty()
                lastParty.isShutdown = true
            }
            
            state.isCameraViewPresented = true
            
            // 이전 스텝 사진 찍고, 다시 들어와보니 이미 다음 스텝 진행중
            if restTime <= TimeInterval(stepTime) {
                let newStep = Step()
                lastParty.stepList.append(newStep)
            } else {
                NotificationManager.instance.scheduleFunction(date: nextStepStartDate) {
                    let newStep = Step()
                    lastParty.stepList.append(newStep)
                }
            }
        }
        
        // 이전 스텝 사진 찍고, 다시 들어와보니 다음 스텝 종료됨
        else {
            finishParty()
            lastParty.isShutdown = true
        }
    }
}

// MARK: - Presentaion

extension PartyUseCase {
    
    /// CameraView를 컨트롤합니다.
    func presentCameraView(to bool: Bool) {
        state.isCameraViewPresented = bool
    }
    
    /// ResultView를 컨트롤합니다.
    func presentResultView(to bool: Bool) {
        state.isResultViewPresented = bool
    }
}
