//
//  MockModelContainer.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/18/24.
//

import Foundation
import SwiftData

struct MockModelContainer {
    
    /// 목업용으로 사용할 SwiftData ModelContainer
    static var mockModelContainer: ModelContainer = {
        let schema = Schema([Party.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            return container
        } catch {
            fatalError("MockModelContainer 생성 실패: \(error)")
        }
    }()
}
