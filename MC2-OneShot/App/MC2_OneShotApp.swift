//
//  MC2_OneShotApp.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - App

@main
struct MC2_OneShotApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    private let modelContainer = ModelContainerCoordinator.main
    
    var body: some Scene {
        WindowGroup {
            HomeView(
                partyUseCase: PartyUseCase(
                    dataService: PersistentDataService(modelContext: modelContainer.mainContext),
                    notificationService: NotificationService()
                )
            )
        }
        .modelContainer(modelContainer)
    }
}
