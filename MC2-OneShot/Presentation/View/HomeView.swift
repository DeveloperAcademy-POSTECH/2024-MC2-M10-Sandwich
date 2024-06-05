//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {
    
    @State private(set) var partyUseCase: PartyUseCase
    
    @StateObject private var homePathModel: HomePathModel = .init()
    
    @State private var isPartySetViewPresented = false
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        NavigationStack(path: $homePathModel.paths) {
            VStack(alignment: .leading) {
                HeaderView()
                ListView()
                ActionButton(
                    title: partyUseCase.state.isPartyLive ? "사진 찍으러 가기" : "술자리 생성하기",
                    buttonType: partyUseCase.state.isPartyLive ? .popupfinish : .primary
                ) {
                    if partyUseCase.partys.isLastParyLive {
                        partyUseCase.presentCameraView(to: true)
                    } else {
                        isPartySetViewPresented.toggle()
                    }
                }
                .padding(.horizontal, 16)
            }
            .homePathDestination()
            .sheet(isPresented: $isPartySetViewPresented) {
                PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
            }
        }
        .fullScreenCover(isPresented: $state.isCameraViewPresented) {
            PartyCameraView(cameraUseCase: CameraUseCase(cameraService: CameraService()))
        }
        .environment(partyUseCase)
        .environmentObject(homePathModel)
        .onAppear {
            setupNotification()
            
            if partyUseCase.state.isPartyLive {
                setupPartyService()
            }
            
            if partyUseCase.state.isPartyLive,
               let lastParty = partyUseCase.partys.lastParty,
               let lastStep = lastParty.sortedStepList.last {
                print("1. 만약 현재 파티가 Live 상태이고")
                let presentTime = Date.now.timeIntervalSince1970
                
                if lastStep.mediaList.isEmpty {
                    print("2-1. 마지막 스텝의 미디어가 비어있다면(아직 미션을 완료하지 않았다면)")
                    whenLastStepNotComplete(lastParty: lastParty, presentTime: presentTime)
                } else {
                    print("2-2. 마지막 스텝의 미디어가 한 개 이상 있다면(미션을 완료했다면)")
                    whenLastStepComplete(lastParty: lastParty, presentTime: presentTime)
                }
            }
        }
    }
}

// MARK: - HeaderView

private struct HeaderView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    var body: some View {
        HStack{
            Spacer()
            Button {
                homePathModel.paths.append(.searchList)
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.shotFF)
                    .padding(.trailing, 16)
            }
        }
        
        Image(.appLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 35)
            .padding(.leading, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

// MARK: - ListView

private struct ListView: View {
    
    @Query private var partys: [Party]
    
    @State private var isFirstInfoVisible = true
    
    var body: some View {
        ZStack {
            Image(.firstInfo)
                .padding(.bottom, 48)
                .opacity(partys.isEmpty ? 1 : 0)
            
            TableListView(isFirstInfoVisible: $isFirstInfoVisible)
        }
    }
}

// MARK: - HomeView Function

extension HomeView {
    
    /// 초기 Notification을 설정합니다.
    private func setupNotification() {
        NotificationManager.instance.requestAuthorization()
        NotificationManager.instance.resetBadge()
    }
    
    /// 앱을 실행할 때마다 startDate와 notiCycle을 갱신
    private func setupPartyService() {
        
        guard let party = partyUseCase.partys.lastParty else {
            print("현재 진행 중인 파티가 없습니다.")
            return
        }
        
        let currentStartDate = party.startDate
        let currentNotiCycle = NotiCycle(rawValue: party.notiCycle) ?? .min30
        
        PartyService.shared.setPartyService(startDate: currentStartDate, notiCycle: currentNotiCycle)
    }
    
    /// PartySetView가 사라질 때 호출되는 메서드입니다.
    private func presentCameraView() {
        // isCameraViewPresented.toggle()
        
        //        NotificationManager.instance.scheduleFunction(date: PartyService.shared.currentStepEndDate) {
        //            isPartyResultViewPresented.toggle()
        //        }
    }
    
    /// STEP을 완료하지 못했을 때 로직
    private func whenLastStepNotComplete(lastParty: Party, presentTime: TimeInterval) {
        let shutdownStepSecond = TimeInterval(lastParty.stepList.count) * TimeInterval(lastParty.notiCycle * 60)
        let currentStepEndDate = lastParty.startDate.timeIntervalSince1970 + shutdownStepSecond
        
        let restTime = currentStepEndDate - presentTime
        
        //        // 현재Step마지막 - 현재시간 > 0 : 초과 아닐 때
        //        if restTime > 0 {
        //            NotificationManager.instance.scheduleFunction(date: Date(timeIntervalSince1970: currentStepEndDate)) {
        //                isPartyResultViewPresented.toggle()
        //                lastParty.isShutdown = true
        //            }
        //
        //            isCameraViewPresented.toggle()
        //        }
        //
        //        // 현재Step마지막 - 현재시간 > 0 : 초과일 때
        //        else {
        //            isPartyResultViewPresented.toggle()
        //            lastParty.isShutdown = true
        //        }
    }
    
    /// STEP을 완료했을 때 로직
    private func whenLastStepComplete(lastParty: Party, presentTime: TimeInterval) {
        let shutdownStepSecond = TimeInterval((lastParty.stepList.count + 1)) * TimeInterval(lastParty.notiCycle * 60)
        let nextStepEndDate = lastParty.startDate.timeIntervalSince1970 + shutdownStepSecond
        let nextStepStartDate = lastParty.startDate.timeIntervalSince1970 + TimeInterval(lastParty.stepList.count) * TimeInterval(lastParty.notiCycle * 60)
        
        let restTime = nextStepEndDate - presentTime
        
        if restTime > 0 {
            NotificationManager.instance.scheduleFunction(date: Date(timeIntervalSince1970: nextStepEndDate)) {
                // isPartyResultViewPresented.toggle()
                lastParty.isShutdown = true
            }
            
            // isCameraViewPresented.toggle()
            
            // 이전 스텝 사진 찍고, 다시 들어와보니 이미 다음 스텝 진행중
            if restTime <= TimeInterval(lastParty.notiCycle * 60) {
                let newStep = Step()
                lastParty.stepList.append(newStep)
            } else {
                NotificationManager.instance.scheduleFunction(date: Date(timeIntervalSince1970: nextStepStartDate)) {
                    let newStep = Step()
                    lastParty.stepList.append(newStep)
                }
            }
        }
        
        // 이전 스텝 사진 찍고, 다시 들어와보니 다음 스텝 종료됨
        else {
            // isPartyResultViewPresented.toggle()
            lastParty.isShutdown = true
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let modelContext = MockModelContainer.mockModelContainer.mainContext
    
    return HomeView(
        partyUseCase: PartyUseCase(
            dataService: PersistentDataService(modelContext: modelContext)
        )
    )
    .environmentObject(HomePathModel())
    .modelContainer(MockModelContainer.mockModelContainer)
}
#endif
