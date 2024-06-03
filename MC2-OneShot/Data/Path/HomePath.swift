//
//  HomePath.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import Foundation
import SwiftUI

/// HomeView에서 이동할 수 있는 PathType
enum HomePathType: Hashable {
    case partyList(party: Party) /// 파티 리스트
    case searchList /// 리스트 검색
}

/// HomePath 관리를 위한 Model
final class HomePathModel: PathModel {
    
    /// 데이터 추적을 위한 배열
    @Published var paths: [HomePathType]
    
    init(paths: [HomePathType] = []) {
        self.paths = paths
    }
}

/// HomePathModel 지정을 위한 ViewModifier
private struct HomePathDestination: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: HomePathType.self) { path in
                switch path {
                case let .partyList(party): PartyListView(
                    party: party,
                    isCameraViewPresented: .constant(false)
                )
                case .searchList: SearchView()
                }
            }
    }
}

extension View {
    
    /// HomePathModel을 이용해 NavigationDestination을 지정합니다.
    func homePathDestination() -> some View {
        self.modifier(HomePathDestination())
    }
}
