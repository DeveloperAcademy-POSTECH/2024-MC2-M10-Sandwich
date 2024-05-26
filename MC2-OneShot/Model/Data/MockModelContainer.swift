//
//  MockModelContainer.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/18/24.
//

import Foundation
import SwiftData

/// Mock 전용 SwiftData Model Container
struct MockModelContainer {
    
    /// 목업용으로 사용할 SwiftData ModelContainer
    static var mockModelContainer: ModelContainer = {
        
        let schema = Schema([Party.self, Member.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do { return try ModelContainer(for: schema, configurations: [modelConfiguration]) }
        catch { fatalError("MockModelContainer 생성 실패: \(error)") }
    }()
}
