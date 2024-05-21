//
//  PathModel.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import Foundation

protocol PathModel: ObservableObject {
    associatedtype PathType: Hashable
    var paths: [PathType] { get }
}

// MARK: - Home Path
enum HomePathType: Hashable {
    case partyList(party: Party) /// 파티 리스트
    case searchList /// 리스트 검색
}

final class HomePathModel: PathModel {
    
    /// 데이터 추적을 위한 배열
    @Published var paths: [HomePathType]
    
    init(paths: [HomePathType] = []) {
        self.paths = paths
    }
}

// MARK: - Camera Path
enum CameraPathType: Hashable {
    case partyList(party: Party) /// 파티 리스트
}

final class CameraPathModel: PathModel {
    
    /// 데이터 추적을 위한 배열
    @Published var paths: [CameraPathType]
    
    init(paths: [CameraPathType] = []) {
        self.paths = paths
    }
}

///// 어떤 유형의 화면 데이터가 있는지 정의
//enum PathType: Hashable {
//    case partyCamera /// 파티 카메라 View
//    case partyResult /// 파티 결과(완료) View
//    case partyList(party: Party) /// 파티 리스트  View
//    case searchView
//}
//
///// 화면 데이터 흐름을 감지하기 위한 Model
//final class PathModel: ObservableObject {
//    
//    /// 데이터 추적을 위한 배열
//    @Published var paths: [PathType]
//    
//    init(paths: [PathType] = []) {
//        self.paths = paths
//    }
//}
