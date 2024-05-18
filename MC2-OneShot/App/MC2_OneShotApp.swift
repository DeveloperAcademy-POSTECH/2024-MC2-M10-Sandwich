//
//  MC2_OneShotApp.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

@main
struct MC2_OneShotApp: App {
    
    /// SwiftData ModelContainer 생성
    var modelContainer: ModelContainer = {
        
        // 1. Scehema 및 ModelConfiguration 생성
        let schema = Schema([Party.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        // 2. ModelContainer 생성
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("ModelContainer 생성 실패: \(error.localizedDescription)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            InitialView(modelContainer: modelContainer)
        }
        .modelContainer(modelContainer)
    }
}
