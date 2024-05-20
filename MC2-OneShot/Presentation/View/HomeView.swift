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
    
    var modelContainer: ModelContainer
    
    var body: some View {
        HomeView(
            persistentDataManager: PersistentDataManager(
                modelContext: modelContainer.mainContext
            )
        )
    }
}

// MARK: - HomeView
struct HomeView: View {
    
    @StateObject var persistentDataManager: PersistentDataManager
    @StateObject private var pathModel: PathModel = .init()
    
    @State private var isPartySetViewPresented = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            VStack(alignment: .leading) {
                HStack{
                    Spacer()
                    Button {
                        pathModel.paths.append(.searchView)
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(.shotFF)
                            .padding(.trailing, 16)
                    }
                }
                
                Image("appLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 35)
                    .padding(.leading, 16)
                    .padding(.top, 20)
                
                ListView()
                
                ActionButton(
                    title: "GO STEP!",
                    buttonType:.primary
                ) {
                    isPartySetViewPresented.toggle()
                }
                .padding(.horizontal, 16)
            }
            .navigationDestination(for: PathType.self) { path in
                switch path {
                case .partySet: PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
                case .partyCamera: PartyCameraView()
                case .partyList: PartyListView()
                case .partyResult: PartyResultView()
                case .searchView: SearchView()
                }
            }
            .sheet(isPresented: $isPartySetViewPresented) {
                PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                
            }
        }
        .environmentObject(pathModel)
        .environmentObject(persistentDataManager)
    }
}

// MARK: - ListView
private struct ListView: View {
    
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject var persistentDataManager: PersistentDataManager
    
    @Query private var partys: [Party]
    @State private var searchText = ""
    
    var body: some View {
        List(partys) { party in
            ListCellView(
                thumbnail: "image", // TODO: 랜덤 썸네일 뽑는 로직 추가
                title: party.title,
                captureDate: party.startDate,
                isLive: party.isLive,
                stepCount: party.stepList.count,
                notiCycle: party.notiCycle
            )
            .onTapGesture {
                pathModel.paths.append(.partyList)
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
}

// MARK: - ListCellView
private struct ListCellView: View {
    
    let thumbnail: String
    let title: String
    let captureDate: Date
    let isLive: Bool
    let stepCount: Int
    let notiCycle: Int
    
    var body: some View {
        HStack {
            Image(.test)
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
        .environmentObject(PathModel())
        .modelContainer(MockModelContainer.mockModelContainer)
}
