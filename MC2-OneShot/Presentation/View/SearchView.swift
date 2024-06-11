//
//  SearchView.swift
//  MC2-OneShot
//
//  Created by p_go.ne on 5/18/24.
//

import SwiftUI

// MARK: - SearchView

struct SearchView: View {
    
    @Environment(HomePathModel.self) private var homePathModel
    
    @State private var searchText = ""
    
    var body: some View {
        Group {
            if searchText.isEmpty {
                Image(.imgLogo)
                    .padding(.bottom, 60)
                    .opacity(0.1)
            } else {
                ListView(searchText: $searchText)
                    .searchable(
                        text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "기억하고 싶은 술자리를 검색해 보세요"
                    )
            }
        }
        .navigationTitle("검색하기")
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    homePathModel.paths.removeAll()
                } label: {
                    Image(symbol: .chevronLeft)
                        .foregroundStyle(.shotFF)
                }
            }
        }
    }
}

// MARK: - ListView

private struct ListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(HomePathModel.self) private var homePathModel
    
    @Binding var searchText: String
    
    var body: some View {
        List(searchPartys) { party in
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
        }
        .listStyle(.plain)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
    
    /// 검색어를 이용해 Party 배열을 반환합니다.
    private var searchPartys: [Party] {
        partyUseCase.partys.filter {
            $0.title.contains(searchText)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchView()
        .environment(HomePathModel())
}
#endif
