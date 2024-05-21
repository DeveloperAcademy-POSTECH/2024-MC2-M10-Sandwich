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
            if UserDefaults.standard.isPartyLive {
                updatePartyService()
            }
        }
    }
    
    /// 앱을 실행할 때마다 startDate와 notiCycle을 갱신
    func updatePartyService() {
        
        guard let party = partys.last else {
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
                    .padding(.top, 20)
                
                ListView()
                
                ActionButton(
                    title: isCurrentPartyLive ? "술자리 돌아가기" : "술자리 생성하기",
                    buttonType: isCurrentPartyLive ? .secondary : .primary
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
                    
                    NotificationManager.instance.scheduleFunction(date: PartyService.shared.testDate) {
                        isPartyResultViewPresented.toggle()
                        UserDefaults.standard.updatePartyLive(isLive: false)
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
    }
}

// MARK: - ListView
private struct ListView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    @EnvironmentObject var persistentDataManager: PersistentDataManager
    
    @Query private var partys: [Party]
    
    var body: some View {
        List(partys) { party in
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
            }
            .swipeActions {
                Button {
                    // TODO: 술자리 데이터 삭제 Alert 출력
                    persistentDataManager.deleteParty(party)
                } label: {
                    Text("삭제하기")
                }
                .tint(.red)
            }
        }
        .listStyle(.plain)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    /// 리스트에 보여질 첫번째 썸네일 데이터를 반환합니다.
    func firstThumbnail(_ party: Party) -> Data {
        guard let firstStep = party.stepList.first,
              let firstMedia = firstStep.mediaList.first else {
            // print("썸네일 반환에 실패했습니다.")
            return Data()
        }
        
        return firstMedia.fileData
    }
}

// MARK: - ListCellView
private struct ListCellView: View {
    
    let thumbnail: Data
    let title: String
    let captureDate: Date
    let isLive: Bool
    let stepCount: Int
    let notiCycle: Int
    
    var body: some View {
        HStack {
            Image(uiImage: UIImage(data: thumbnail) ?? UIImage())
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
        Text(stateInfo == .live ? "LIVE" : "STEP_\(stepCount)")
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
