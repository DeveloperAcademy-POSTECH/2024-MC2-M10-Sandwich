//
//  CameraPath.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import SwiftUI

/// CameraView에서 이동할 수 있는 PathType
enum CameraPathType: Hashable {
    case partyList(party: Party) /// 파티 리스트
}

/// CameraPath 관리를 위한 Model
@Observable
final class CameraPathModel: PathModel {
    
    /// 데이터 추적을 위한 배열
    var paths: [CameraPathType]
    
    init(paths: [CameraPathType] = []) {
        self.paths = paths
    }
}

/// HomePathModel 지정을 위한 ViewModifier
private struct CameraPathDestination: ViewModifier {
    func body(content: Content) -> some View {
        content
            .navigationDestination(for: CameraPathType.self) { path in
                switch path {
                case let .partyList(party):
                    PartyListView(party: party)
                        .toolbarRole(.editor)
                }
            }
    }
}

extension View {
    
    /// CameraPathModel을 이용해 NavigationDestination을 지정합니다.
    func cameraPathDestination() -> some View {
        self.modifier(CameraPathDestination())
    }
}
