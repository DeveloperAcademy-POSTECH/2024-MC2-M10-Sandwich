//
//  CameraPath.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import Foundation

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
