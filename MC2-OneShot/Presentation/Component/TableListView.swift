//
//  TableListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import SwiftUI
import SwiftData

struct TableListView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var isShowAlert = false
    @State private var selectedParty: Party?
    @Binding var isFirstInfoVisible: Bool
    
    @Query private var partys: [Party]
    
    var body: some View {
        List(partys.sortedPartys.reversed()) { party in
            TableListCellView(
                thumbnail: party.firstThumbnailData,
                title: party.title,
                captureDate: party.startDate,
                isLive: party.isLive,
                stepCount: party.stepList.count,
                notiCycle: party.notiCycle
            )
            .onAppear{
                isFirstInfoVisible = partys.isEmpty
            }
            .onTapGesture {
                homePathModel.paths.append(.partyList(party: party))
            }
            .swipeActions {
                Button {
                    selectedParty = party
                    self.isShowAlert.toggle()
                } label: {
                    Text("삭제하기")
                }
                .tint(.red)
            }
            .alert(deletePartyAlertText, isPresented: $isShowAlert) {
                if selectedParty?.isLive ?? false {
                    Button("확인", role: .none) {}
                } else {
                    Button("지우기", role: .destructive) {
                        guard let selectedParty = selectedParty else { return }
                        HapticManager.shared.notification(type: .success)
                        modelContext.delete(selectedParty)
                        isFirstInfoVisible = partys.isEmpty
                    }
                    
                    Button("살리기", role: .cancel) {}
                }
            }
        }
        .listStyle(.plain)
    }
    
    /// 리스트에서 파티를 삭제할 때 출력되는 텍스트입니다.
    private var deletePartyAlertText: String {
        guard let selectedParty = selectedParty else { return "" }
        if selectedParty.isLive { return "진행중인 술자리는 지울 수 없어,,," }
        else { return "진짤루?\n 술자리 기억...지우..는거야..?" }
    }
}

// MARK: - TableListCellView
struct TableListCellView: View {
    
    let thumbnail: UIImage
    let title: String
    let captureDate: Date
    let isLive: Bool
    let stepCount: Int
    let notiCycle: Int
    
    var body: some View {
        HStack {
            Image(uiImage: thumbnail)
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
                TableListStateInfoLabel(
                    stateInfo: isLive ? .live : .end,
                    stepCount: stepCount
                )
                
                Text("\(notiCycle)min")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
        }
        .background(.shot00)
    }
}

// MARK: - TableListStateInfoLabel
private struct TableListStateInfoLabel: View {
    
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

// MARK: - Preview
#Preview {
    let modelContainer = MockModelContainer.mockModelContainer
    return TableListView(isFirstInfoVisible: .constant(true))
        .environmentObject(HomePathModel())
        .environmentObject(PersistentDataManager(modelContext: modelContainer.mainContext))
        .modelContainer(modelContainer)
}

#Preview {
    TableListCellView(
        thumbnail: UIImage(resource: .test),
        title: "테스트 제목",
        captureDate: .now,
        isLive: true,
        stepCount: 7,
        notiCycle: 30
    )
}