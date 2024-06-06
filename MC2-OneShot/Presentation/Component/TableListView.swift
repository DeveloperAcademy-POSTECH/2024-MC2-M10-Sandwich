//
//  TableListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import SwiftUI

// MARK: - TableListView

struct TableListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(HomePathModel.self) private var homePathModel
    
    @State private var isShowAlert = false
    @State private var selectedParty: Party?
    
    var body: some View {
        List(partyUseCase.partys.reversed()) { party in
            TableListCellView(
                thumbnail: party.firstThumbnailData,
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
                    selectedParty = party
                    isShowAlert.toggle()
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
                        partyUseCase.deleteParty(selectedParty)
                        HapticManager.shared.notification(type: .success)
                    }
                    
                    Button("살리기", role: .cancel) {}
                }
            }
        }
        .listStyle(.plain)
    }
    
    /// 리스트에서 파티를 삭제할 때 출력되는 텍스트입니다.
    private var deletePartyAlertText: String {
        guard let selectedParty = selectedParty else { return "선택된 파티가 없습니다!" }
        if selectedParty.isLive { return "진행중인 술자리는 지울 수 없어,,," }
        else { return "진짤루?\n 술자리 기억...지우..는거야..?" }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let modelContainer = MockModelContainer.mock
    return TableListView()
        .environment(HomePathModel())
        .modelContainer(modelContainer)
}
#endif
