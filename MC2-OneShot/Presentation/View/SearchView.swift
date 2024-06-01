//
//  SearchView.swift
//  MC2-OneShot
//
//  Created by p_go.ne on 5/18/24.
//

import SwiftUI
import SwiftData

// MARK: - SearchView

struct SearchView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
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
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.shotFF)
                }
            }
        }
    }
}

// MARK: - ListView

private struct ListView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    @Binding var searchText: String
    
    @Query private var partys: [Party]
    
    /// 검색어를 이용해 Party 배열을 반환합니다.
    var searchPartys: [Party] {
        partys.filter {
            $0.title.contains(searchText)
        }
    }
    
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
}

// MARK: - Preview

#if DEBUG
#Preview {
    SearchView()
}
#endif
