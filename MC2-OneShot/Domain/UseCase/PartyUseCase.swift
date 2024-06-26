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
    private(set) var members: [Member]
    
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
        self.members = []
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
        HapticManager.shared.notification(type: .success)
        dataService.createParty(party)
        state.isPartyLive = true
        state.startDate = party.startDate
        state.notiCycle = NotiCycle(rawValue: party.notiCycle) ?? .min30
        state.isCameraViewPresented = true
        partys = dataService.fetchPartys()
        whenPartyStart()
    }
    
    /// 파티 사진을 현재 Step에 저장합니다.
    func saveStepPhoto(_ photo: CapturePhoto) {
        guard let currentParty = partys.last,
              let lastStep = currentParty.sortedStepList.last
        else { return }
        
        if lastStep.mediaList.isEmpty {
            dataService.saveStepPhoto(photo)
            stepComplete()
        } else {
            dataService.saveStepPhoto(photo)
        }
        
        partys = dataService.fetchPartys()
    }
    
    /// 멤버 사진을 저장합니다.
    func saveMemberPhoto(_ photo: CapturePhoto) {
        HapticManager.shared.notification(type: .success)
        let newMember = dataService.saveMemberPhoto(photo)
        members.append(newMember)
    }
    
    /// 파티를 종료합니다.
    func finishParty(isShutdown: Bool) {
        guard let currentParty = partys.last,
              let lastStep = currentParty.sortedStepList.last
        else { return }
        
        // 데이터 업데이트
        currentParty.isLive = false
        currentParty.isShutdown = isShutdown
        if lastStep.mediaList.isEmpty { dataService.deleteStep(lastStep) }
        partys = dataService.fetchPartys()
        
        // 상태 값 업데이트
        state.isResultViewPresented = true
        state.isPartyLive = false
        
        // Notification 예약 취소
        cancelAllSchedule()
    }
    
    /// 선택한 파티를 삭제합니다.
    func deleteParty(_ party: Party) {
        dataService.deleteParty(party)
        partys = dataService.fetchPartys()
    }
    
    /// 파티 설정을 초기화합니다.
    func resetPartySetting() {
        self.members = []
    }
}

// MARK: - Helper

extension PartyUseCase {
    
    /// Step을 완료했을 때 실행되는 로직입니다.
    private func stepComplete() {
        
        HapticManager.shared.notification(type: .success)
        
        // 1. 예약된 스케줄 모두 취소
        cancelAllSchedule()
        
        // 2. 다음 STEP 알림 예약
        notificationService.scheduleNotification(
            date: nextStepStartDate,
            title: "STEP \((currentStep + 1).intformatter)",
            subtitle: NotificationTitle.continuePartySubTitle
        )
        
        // 3. 다음 스텝 강제 종료 10분전 알림 예약
        notificationService.scheduleNotification(
            date: nextShutdownWarningDate,
            title: NotificationTitle.shutdownWarningTitle,
            subtitle: NotificationTitle.shutdownWarningSubTitle
        )
        
        // 4. 다음 스텝 강제 종료 되었을 때 알림 예약
        notificationService.scheduleNotification(
            date: nextStepEndDate,
            title: NotificationTitle.shutdownTitle,
            subtitle: NotificationTitle.shutdownSubTitle
        )
        
        // 5. 다음 스텝 강제 종료 되었을 때 함수 예약
        notificationService.scheduleFunction(date: nextStepEndDate) { [weak self] in
            self?.finishParty(isShutdown: true)
        }
        
        // 6. 새로운 빈 STEP 생성 예약
        notificationService.scheduleFunction(date: nextStepStartDate) { [weak self] in
            let newStep = Step()
            self?.partys.last?.stepList.append(newStep)
        }
    }
    
    /// 예약된 모든 함수 및 Notification을 취소합니다.
    private func cancelAllSchedule() {
        notificationService.cancelAllPendingFunction()
        notificationService.cancelAllPendingNotification()
    }
    
    /// Party가 시작됐을 때 실행되는 로직
    private func whenPartyStart() {
        
        // 1. 강제 종료 10분 전 예약 - 소리 + 배너
        notificationService.scheduleNotification(
            date: currentShutdownWarningDate,
            title: NotificationTitle.shutdownWarningTitle,
            subtitle: NotificationTitle.shutdownWarningSubTitle
        )
        
        // 2. 강제 종료 되었을 때 예약 - 배너
        notificationService.scheduleNotification(
            date: currentStepEndDate,
            title: NotificationTitle.shutdownTitle,
            subtitle: NotificationTitle.shutdownSubTitle
        )
        
        // 3. 강제 종료 되었을 때 - 결과 화면
        notificationService.scheduleFunction(date: currentStepEndDate) {
            [weak self] in
            self?.finishParty(isShutdown: true)
        }
    }
    
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
                self?.finishParty(isShutdown: true)
            }
            
            state.isCameraViewPresented = true
        }
        
        // 현재Step마지막 - 현재시간 > 0 : 초과일 때
        else {
            finishParty(isShutdown: true)
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
            notificationService.scheduleFunction(date: nextStepEndDate) {
                [weak self] in
                self?.finishParty(isShutdown: true)
            }
            
            state.isCameraViewPresented = true
            
            // 이전 스텝 사진 찍고, 다시 들어와보니 이미 다음 스텝 진행중
            if restTime <= TimeInterval(stepTime) {
                let newStep = Step()
                lastParty.stepList.append(newStep)
            } else {
                notificationService.scheduleFunction(date: nextStepStartDate) {
                    let newStep = Step()
                    lastParty.stepList.append(newStep)
                }
            }
        }
        
        // 이전 스텝 사진 찍고, 다시 들어와보니 다음 스텝 종료됨
        else { finishParty(isShutdown: true) }
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

// MARK: - Schedule Date

extension PartyUseCase {
    
    /// 현재 STEP이 몇번째인지 반환하는 계산 속성
    private var currentStep: Int {
        guard let currentParty = partys.last else { return 0 }
        return currentParty.stepList.count
    }
    
    /// 현재 STEP의 마지막 시점 Date를 반환하는 계산 속성
    private var currentStepEndDate: Date {
        let shutdownStepSecond = TimeInterval(currentStep * state.notiCycle.toSeconds)
        let shutdownSecond = state.startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 현재 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    private var currentShutdownWarningDate: Date {
        let shutDownWarningSecond = currentStepEndDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
    
    /// 다음 STEP의 시작 시점 Date를 반환하는 계산 속성
    private var nextStepStartDate: Date {
        let currentStepEndSecond = currentStep * state.notiCycle.toSeconds
        let shutdownStepTime = TimeInterval(currentStepEndSecond + 1)
        let shutdownSecond = state.startDate.timeIntervalSince1970 + shutdownStepTime
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 다음 STEP의 마지막 시점 Date를 반환하는 계산 속성
    private var nextStepEndDate: Date {
        let shutdownStepSecond = TimeInterval((currentStep + 1) * state.notiCycle.toSeconds)
        let shutdownSecond = state.startDate.timeIntervalSince1970 + shutdownStepSecond
        return Date(timeIntervalSince1970: shutdownSecond)
    }
    
    /// 다음 STEP의 강제 종료 10분전 시점 Date를 반환하는 계산 속성
    private var nextShutdownWarningDate: Date {
        let shutDownWarningSecond = nextStepEndDate.timeIntervalSince1970 - TimeInterval(600)
        return Date(timeIntervalSince1970: shutDownWarningSecond)
    }
}
