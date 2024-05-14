//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var pathModel: PathModel = .init()
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
            Text("HomeView")
                .navigationDestination(for: PathType.self) { path in
                    switch path {
                    case .partySet: PartySetView()
                    case .partyCamera: PartyCameraView()
                    case .partyList: PartyListView()
                    case .partyResult: PartyResultView()
                    }
                }
        }
        .environmentObject(pathModel)
    }
}

#Preview {
    HomeView()
        .environmentObject(PathModel())
}
