//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct HomeView: View {
    
    @StateObject private var pathModel: PathModel = .init()
    
    // 1. 더미데이터 예시
    // 요렇게 데이터를 만들어서 뷰에서 가져다 쓰세요
//    let partys: [Party] = [
//        Party(
//            title: "안녕하세요",
//            startDate: Date(),
//            notiCycle: 30
//        )
//    ]
    
    var body: some View {
        NavigationStack(path: $pathModel.paths) {
//            List(partys) { party in
//                Text("\(party.title)")
//            }
            Text("HomeView")
                 .pretendard(.extraBold, 30)
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
