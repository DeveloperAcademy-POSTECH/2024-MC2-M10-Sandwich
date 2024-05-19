//
//  PathModel.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import Foundation

/// 어떤 유형의 화면 데이터가 있는지 정의
enum PathType: Hashable {
    case partySet ///  파티 설정(생성) View
    case partyCamera /// 파티 카메라 View
    case partyResult /// 파티 결과(완료) View
    case partyList /// 파티 리스트  View
    case searchView
}

/// 화면 데이터 흐름을 감지하기 위한 Model
final class PathModel: ObservableObject {
    
    /// 데이터 추적을 위한 배열
    @Published var paths: [PathType]
    
    init(paths: [PathType] = []) {
        self.paths = paths
    }
    
    /// pathModel.paths.append(.partyCamera) - 다음 화면 이동
    /// pathModel.paths.removeLast() - 이전 화면 이동
    /// pathModel.paths.removeAll() - 첫번째 화면(RootView) 이동
}
