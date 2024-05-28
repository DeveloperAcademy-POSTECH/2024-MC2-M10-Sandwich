//
//  SearchView.swift
//  MC2-OneShot
//
//  Created by p_go.ne on 5/18/24.
//

import SwiftUI
import SwiftData

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
    
    @Query private var partys: [Party]
    @Binding var searchText: String
    
    var searchPartys: [Party]{
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
            .swipeActions {
                Button {
                    // TODO: 술자리 데이터 삭제 Alert 출력
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

#Preview {
    SearchView()
}
