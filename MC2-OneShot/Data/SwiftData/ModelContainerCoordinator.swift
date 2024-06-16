//
//  ModelContainerCoordinator.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/16/24.
//

import SwiftData

/// SwiftData Model Container
struct ModelContainerCoordinator {
    
    /// 메인 SwiftData ModelContainer
    static var main: ModelContainer = {
        let schema = Schema([Party.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(
                for: schema,
                migrationPlan: OneShotMigrationPlan.self,
                configurations: [configuration]
            )
        }
        catch { fatalError("ModelContainer 생성 실패: \(error.localizedDescription)") }
    }()
    
    /// 목업용으로 사용할 SwiftData ModelContainer
    static var mock: ModelContainer = {
        let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try! ModelContainer(
            for: Party.self,
            migrationPlan: OneShotMigrationPlan.self,
            configurations: modelConfiguration
        )
    }()
}
