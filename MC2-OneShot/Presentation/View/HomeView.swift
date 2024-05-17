//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import Combine

struct HomeView: View {
    
    @StateObject private var pathModel: PathModel = .init()
    @State private var isPartySetViewPresented = false
    
    private var lifeCycleManager: LifeCycleManager = .init()
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            VStack {
                ListView()
                ActionButton(
                    title: "GO STEP!",
                    buttonType:.primary
                ) {
                    isPartySetViewPresented.toggle()
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("ONE SHOT")
            .navigationDestination(for: PathType.self) { path in
                switch path {
                case .partySet: PartySetView(isPartySetViewPresented: .constant(false))
                case .partyCamera: PartyCameraView()
                case .partyList: PartyListView()
                case .partyResult: PartyResultView()
                }
            }
            .sheet(isPresented: $isPartySetViewPresented) {
                PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
            }
            .onReceive(lifeCycleManager.mergeLifeCyclePublishers()) { event in
                print("\(event.name)")
            }
        }
        .environmentObject(pathModel)
    }
}

// MARK: - ListView
private struct ListView: View {
    
    @State private var searchText = ""
    
    var body: some View {
        List(dummyPartys) { party in
            ListCellView(
                thumbnail: "image", // TODO: 랜덤 썸네일 뽑는 로직 추가
                title: party.title,
                captureDate: party.startDate,
                isLive: party.isLive,
                stepCount: party.stepList.count,
                notiCycle: party.notiCycle
            )
            .swipeActions {
                Button {
                    // TODO: 술자리 데이터 삭제 Alert 출력
                } label: {
                    Text("삭제하기")
                }
                .tint(.red)
            }
        }
        .searchable(
            text: $searchText,
            prompt: "술자리를 검색해보세요"
        )
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
            Image(systemName: "wineglass.fill")
                .resizable()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
            
            Spacer()
                .frame(width: 8)
            
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
            .background(stateInfo == .live ? .shotBlue : .shotGreen)
            .foregroundStyle(stateInfo == .live ? .shotFF : .shot00)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    HomeView()
        .environmentObject(PathModel())
}
