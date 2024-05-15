//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var pathModel: PathModel = .init()
    
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            VStack {
                ListView()
                Spacer()
                ActionButton(
                    title: "GO STEP!",
                    buttonType:.primary
                ) {
                    pathModel.paths.append(.partySet)
                }
                .padding(.horizontal, 16)
            }
            .navigationTitle("ONE SHOT")
            .navigationDestination(for: PathType.self) { path in
                switch path {
                case .partySet: PartySetView()
                case .partyCamera: PartyCameraView()
                case .partyList: PartyListView()
                case .partyResult: PartyResultView()
                }
            }
            .searchable(
                text: $searchText,
                prompt: "술자리를 검색해보세요"
            )
        }
        .environmentObject(pathModel)
    }
}

// MARK: - ListView
private struct ListView: View {
    var body: some View {
        ScrollView {
            ForEach(dummyPartys) { party in
                VStack(alignment: .leading, spacing: 0) {
                    ListCellView(
                        thumbnail: "image", // TODO: 랜덤 썸네일 뽑는 로직 추가
                        title: party.title,
                        captureDate: party.startDate,
                        isLive: party.isLive,
                        notiCycle: party.notiCycle
                    )
                }
            }
        }
        .padding(.bottom, 16)
    }
}

// MARK: - ListCellView
private struct ListCellView: View {
    
    let thumbnail: String
    let title: String
    let captureDate: Date
    let isLive: Bool
    let notiCycle: Int
    
    var body: some View {
        HStack {
            Image(systemName: "wineglass.fill")
                .resizable()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .pretendard(.bold, 17)
                    .foregroundStyle(.shotFF)
                
                Text("\(captureDate)")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
            
            Spacer()
                .frame(width: 8)
            
            VStack(spacing: 6) {
                Button {
                    
                } label: {
                    Text("LIVE")
                }
                
                Text("\(notiCycle)min")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    HomeView()
        .environmentObject(PathModel())
}
