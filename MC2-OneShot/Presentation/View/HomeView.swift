//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - InitialView
/// PersistentDataManager 생성을 위한 View
struct InitialView: View {
    
    @Query private var partys: [Party]
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    /// 현재 파티가 라이브인지 확인하는 계산 속성
    var isCurrentPartyLive: Bool {
        if let safeParty = currentParty {
            return safeParty.isLive
        } else {
            return false
        }
    }
    
    var modelContainer: ModelContainer
    
    var body: some View {
        HomeView(
            persistentDataManager: PersistentDataManager(
                modelContext: modelContainer.mainContext
            )
        )
        .onAppear {
            NotificationManager.instance.requestAuthorization()
            
            // 라이브 중일 때 함수 호출
            if isCurrentPartyLive {
                updatePartyService()
            }
        }
    }
    
    /// 앱을 실행할 때마다 startDate와 notiCycle을 갱신
    func updatePartyService() {
        
        guard let party = currentParty else {
            print("파티 없음")
            return
        }
        
        let currentStartDate = party.startDate
        let currentNotiCycle = NotiCycle(rawValue: party.notiCycle) ?? .min30
        
        PartyService.shared.setPartyService(startDate: currentStartDate, notiCycle: currentNotiCycle)
    }
}

// MARK: - HomeView
struct HomeView: View {
    
    @StateObject var persistentDataManager: PersistentDataManager
    @StateObject private var homePathModel: HomePathModel = .init()
    
    @State private var isPartySetViewPresented = false
    @State private var isCameraViewPresented = false
    @State private var isPartyResultViewPresented = false
    
    @Query private var partys: [Party]
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        return partys.last
    }
    
    /// 현재 파티가 라이브인지 확인하는 계산 속성
    var isCurrentPartyLive: Bool {
        if let safeParty = currentParty {
            return safeParty.isLive
        } else {
            return false
        }
    }
    
    @State private var isFirstInfoVisible: Bool = true
    
    // 리스트 생성시 이미지 삭제
//    @State private var isFirstInfoVisible = true
    
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
                    // 짐승거인 정혜정..
                }
                
                Image(.appLogo)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 35)
                    .padding(.leading, 16)
                    .padding(.top, 20)
                    .padding(.bottom, 4)
//                Divider()
                ZStack{
                    // 리스트 생성시 이미지 삭제

                    if partys.isEmpty {
                        Image(.firstInfo)
                    }
                    
//                파티스를 하나로 집어넣음 (루시아가 설명할 거임)
                    ListView(isFirstInfoVisible: $isFirstInfoVisible, partys: partys)
                  
                }

                ActionButton(
                                                                 // 내용 바꿈
                    title: isCurrentPartyLive ? "술자리 돌아가기" : "사진찍으러 가기",
                    buttonType: isCurrentPartyLive ? .popupfinish : .primary
                ) {
                    if isCurrentPartyLive {
                        isCameraViewPresented.toggle()
                    } else {
                        isPartySetViewPresented.toggle()
                    }
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(for: HomePathType.self) { path in
                switch path {
                case let .partyList(party): PartyListView(party: party, isCameraViewPresented: .constant(false))
                case .searchList: SearchView()
                }
            }
            
            .sheet(isPresented: $isPartySetViewPresented, onDismiss: {
                if isCurrentPartyLive {
                    isCameraViewPresented.toggle()
                    
                    // 결과화면 present에 예약
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
        .environmentObject(homePathModel)
        .environmentObject(persistentDataManager)
        .onAppear() {
            if isCurrentPartyLive {
                if let currentParty = currentParty,
                   let lastStep = currentParty.lastStep {
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
                            }
                            
                            print("현재Step마지막 - 현재시간 > 0 : 초과X -> 카메라")
                            isCameraViewPresented.toggle()
                        
                        }
                        // 현재Step마지막 - 현재시간 > 0 : 초과일 때
                        else {
                            print("현재Step마지막 - 현재시간 > 0 : 초과O -> result")
                            isPartyResultViewPresented.toggle()
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
                        }
                    }
                }
            }
            
        }
    }
}

// MARK: - ListView
private struct ListView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    @EnvironmentObject var persistentDataManager: PersistentDataManager
    
    @State private var showAlert = false
    
    @Binding var isFirstInfoVisible: Bool
    
//    @Query private var partys: [Party] 두번 쿼리 불러오는거 방지하기 위해 일케 씀
    var partys: [Party]
    
    init(isFirstInfoVisible: Binding<Bool>, partys: [Party]) {
        self._isFirstInfoVisible = isFirstInfoVisible
        self.partys = partys
    }
    
    var body: some View {
        List(partys.sorted { $0.startDate > $1.startDate }) { party in
            ListCellView(
                thumbnail: firstThumbnail(party),
                title: party.title,
                captureDate: party.startDate,
                isLive: party.isLive,
                stepCount: party.stepList.count,
                notiCycle: party.notiCycle
            )
            .onTapGesture {
                homePathModel.paths.append(.partyList(party: party))
                isFirstInfoVisible = partys.isEmpty
            }
            .swipeActions {
                Button {
                    // TODO: 술자리 데이터 삭제 Alert 출력
                    self.showAlert = true
                    
                    //partys가 EMPTY 일때 뒤의 이미지가 보여지도록 도와주는 함수
                    isFirstInfoVisible = partys.isEmpty
                
                    
                } label: {
                    Text("삭제하기")
                }
                .tint(.red)
                
            
            } .onAppear{
                //alert
                isFirstInfoVisible = partys.isEmpty
            }
            .alert(party.isLive ? Text("진행중인 술자리는 지울 수 없어,, ") :Text("진짤루?\n 술자리 기억...지우..는거야..?"),isPresented: $showAlert) {
                if party.isLive{
                    Button(role: .cancel) {
                    } label: {
                        Text("확인")
                    }
                }else{
                    Button(role: .destructive) {
                        persistentDataManager.deleteParty(party)
                    } label: {
                        Text("지우기")
                    }
                    Button(role: .cancel) {
                    } label: {
                        Text("살리기")
                    }
                }
                
            }
        }
        

            
                   
                    
        //partys가 EMPTY 일때 뒤의 이미지가 보여지도록 도와주는 함수
       
        .listStyle(.plain)
//        .padding(.top, 1)
//        .padding(.bottom, 16)
    }
    
    /// 리스트에 보여질 첫번째 썸네일 데이터를 반환합니다.
    func firstThumbnail(_ party: Party) -> Data? {
        let firstStep = party.stepList.first
        let firstMedia = firstStep?.mediaList.first
        return firstMedia?.fileData
    }
}

// MARK: - ListCellView
private struct ListCellView: View {
    
    let thumbnail: Data?
    let title: String
    let captureDate: Date
    let isLive: Bool
    let stepCount: Int
    let notiCycle: Int
    
    var thumbnailLogic: UIImage {
        if let thumbnail = thumbnail,
           let uiImage = UIImage(data: thumbnail) {
            return uiImage
        } else {
            return UIImage(resource: .noImageSign)
        }
    }
    
    var body: some View {
        HStack {
            Image(uiImage: thumbnailLogic)
                .resizable()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
            
            Spacer()
                .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .pretendard(.bold, 17)
                    .foregroundStyle(.shotFF)
                
                Text("\(captureDate.yearMonthDay)")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                PartyStateInfoLabel(
                    stateInfo: isLive ? .live : .end,
                    stepCount: stepCount
                )
                
                Text("\(notiCycle)min")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
        }
    }
}

// MARK: - PartyStateInfoLabel
private struct PartyStateInfoLabel: View {
    
    /// 술자리 상태를 나타내는 열거형
    enum StateInfo: String {
        case live
        case end
    }
    
    let stateInfo: StateInfo
    let stepCount: Int
    
    var body: some View {
        Text(stateInfo == .live ? "LIVE" : "STEP \(stepCount.intformatter)")
            .frame(width: 76, height: 22)
            .pretendard(.bold, 14)
            .background(stateInfo == .live ? .shotGreen : .shot33)
            .foregroundStyle(stateInfo == .live ? .shot00 : .shotD8)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView(persistentDataManager: PersistentDataManager(modelContext: ModelContext(MockModelContainer.mockModelContainer)))
        .environmentObject(HomePathModel())
        .modelContainer(MockModelContainer.mockModelContainer)
}

