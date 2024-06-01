//
//  MC2_OneShotApp.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - App

@main
struct MC2_OneShotApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            HomeView(
                persistentDataManager: PersistentDataManager(
                    modelContext: modelContainer.mainContext
                )
            )
        }
        .modelContainer(modelContainer)
    }
}

// MARK: - SwiftData

extension MC2_OneShotApp {
    
    /// SwiftData ModelContainer 생성
    private var modelContainer: ModelContainer {
        
        let schema = Schema([Party.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do { return try ModelContainer(for: schema, configurations: [configuration]) }
        catch { fatalError("ModelContainer 생성 실패: \(error.localizedDescription)") }
    }
}
