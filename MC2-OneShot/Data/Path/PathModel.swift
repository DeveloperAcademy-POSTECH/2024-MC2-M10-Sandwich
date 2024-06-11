//
//  PathModel.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import Foundation

/// PathModel 인터페이스
protocol PathModel {
    associatedtype PathType: Hashable
    var paths: [PathType] { get }
}
