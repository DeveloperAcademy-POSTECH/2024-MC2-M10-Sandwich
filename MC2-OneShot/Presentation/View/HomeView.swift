//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    
    @StateObject var persistentDataManager: PersistentDataManager
    @StateObject private var homePathModel: HomePathModel = .init()
    
    @State private var isPartySetViewPresented = false
    @State private var isCameraViewPresented = false
    @State private var isPartyResultViewPresented = false
    @State private var isFirstInfoVisible = true
    
    @Query private var partys: [Party]
    
    var body: some View {
        NavigationStack(path: $homePathModel.paths) {
            VStack(alignment: .leading) {
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
                
                ZStack {
                    if partys.isEmpty {
                        Image(.firstInfo)
                            .padding(.bottom, 48)
                    }
                    
                    TableListView(isFirstInfoVisible: $isFirstInfoVisible)
                }
                
                ActionButton(
                    title: partys.isLastParyLive ? "사진 찍으러 가기" : "술자리 생성하기",
                    buttonType: partys.isLastParyLive ? .popupfinish : .primary
                ) {
                    if partys.isLastParyLive { isCameraViewPresented.toggle() }
                    else { isPartySetViewPresented.toggle() }
                }
                .padding(.horizontal, 16)
            }
            .environmentObject(homePathModel)
            .environmentObject(persistentDataManager)
            .navigationDestination(for: HomePathType.self) { path in
                switch path {
                case let .partyList(party): PartyListView(party: party, isCameraViewPresented: .constant(false))
                case .searchList: SearchView()
                }
            }
            .sheet(isPresented: $isPartySetViewPresented, onDismiss: {
                if partys.isLastParyLive {
                    isCameraViewPresented.toggle()
                    
                    NotificationManager.instance.scheduleFunction(date: PartyService.shared.currentStepEndDate) {
                        print("홈뷰에서 결과 화면 실행")
                        isPartyResultViewPresented.toggle()
                    }
                }
            }, content: {
                PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
            })
            .fullScreenCover(isPresented: $isCameraViewPresented) {
                PartyCameraView(isCameraViewPresented: $isCameraViewPresented, isPartyResultViewPresented: $isPartyResultViewPresented)
            }
            .fullScreenCover(isPresented: $isPartyResultViewPresented) {
                isCameraViewPresented = false
            } content: {
                PartyResultView(isPartyResultViewPresented: $isPartyResultViewPresented)
            }
        }
        .onAppear {
            reservationLogic()
        }
    }
}

#Preview {
    HomeView(persistentDataManager: PersistentDataManager(modelContext: ModelContext(MockModelContainer.mockModelContainer)))
        .environmentObject(HomePathModel())
        .modelContainer(MockModelContainer.mockModelContainer)
}

// MARK: - HomeView Function
extension HomeView {
    
    /// 현재 파티 진행 상
    func reservationLogic() {
        if partys.isLastParyLive {
            if let currentParty = partys.lastParty,
               let lastStep = currentParty.sortedStepList.last {
                let presentTime = Date.now.timeIntervalSince1970
                // 만약 마지막 스텝의 사진이 촬영되지 않았다면 (현재미션 미완료중 or 완료후 다음스텝 넘어간후 죽음)
                if lastStep.mediaList.isEmpty {
                    
                    
                    let shutdownStepSecond = TimeInterval(currentParty.stepList.count) * PartyService.shared.getNotiCycle()
                    let currentStepEndDate = currentParty.startDate.timeIntervalSince1970 + shutdownStepSecond
                    
                    let restTime = currentStepEndDate - presentTime
                    
                    // 현재Step마지막 - 현재시간 > 0 : 초과 아닐 때
                    if restTime > 0 {
                        
                        NotificationManager.instance.scheduleFunction(date: Date(timeIntervalSince1970: currentStepEndDate)) {
                            isPartyResultViewPresented.toggle()
                            currentParty.isShutdown = true
                        }
                        
                        print("현재Step마지막 - 현재시간 > 0 : 초과X -> 카메라")
                        isCameraViewPresented.toggle()
                        
                    }
                    // 현재Step마지막 - 현재시간 > 0 : 초과일 때
                    else {
                        print("현재Step마지막 - 현재시간 > 0 : 초과O -> result")
                        isPartyResultViewPresented.toggle()
                        currentParty.isShutdown = true
                    }
                    
                    
                }
                
                // 이전 스텝 사진 찍고
                else {
                    let shutdownStepSecond = TimeInterval((currentParty.stepList.count + 1)) * PartyService.shared.getNotiCycle()
                    let nextStepEndDate = currentParty.startDate.timeIntervalSince1970 + shutdownStepSecond
                    
                    let restTime = nextStepEndDate - presentTime
                    
                    
                    if restTime > 0 {
                        
                        NotificationManager.instance.scheduleFunction(date: Date(timeIntervalSince1970: nextStepEndDate)) {
                            isPartyResultViewPresented.toggle()
                            currentParty.isShutdown = true
                        }
                        
                        isCameraViewPresented.toggle()
                        
                        // 이전 스텝 사진 찍고, 다시 들어와보니 이미 다음 스텝 진행중
                        if restTime <= PartyService.shared.getNotiCycle() {
                            let newStep = Step()
                            currentParty.stepList.append(newStep)
                        }
                    }
                    // 이전 스텝 사진 찍고, 다시 들어와보니 다음 스텝 종료됨
                    else {
                        isPartyResultViewPresented.toggle()
                        currentParty.isShutdown = true
                    }
                }
            }
        }
    }
}
