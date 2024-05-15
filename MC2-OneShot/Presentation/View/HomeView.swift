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

#Preview {
    HomeView()
        .environmentObject(PathModel())
}
