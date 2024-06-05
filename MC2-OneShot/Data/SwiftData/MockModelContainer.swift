//
//  MockModelContainer.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/18/24.
//

// import Foundation
import SwiftData

/// Mock 전용 SwiftData Model Container
struct MockModelContainer {
    
    /// 목업용으로 사용할 SwiftData ModelContainer
    static var mock: ModelContainer = {
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(for: Party.self, configurations: modelConfiguration)
    }()
}
