//
//  InitialView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/26/24.
//

import SwiftUI
import SwiftData

/// PersistentDataManager 생성을 위한 InitialView
struct InitialView: View {
    
    @Query private var partys: [Party]
    
    var modelContainer: ModelContainer
    
    var body: some View {
        HomeView(
            persistentDataManager: PersistentDataManager(
                modelContext: modelContainer.mainContext
            )
        )
        .onAppear {
            setupNotification()
            if partys.isLastParyLive { setupPartyService() }
        }
    }
}

// MARK: - View Funcion
extension InitialView {
    
    /// 초기 Notification을 설정합니다.
    private func setupNotification() {
        NotificationManager.instance.requestAuthorization()
        NotificationManager.instance.resetBadge()
    }
    
    /// 앱을 실행할 때마다 startDate와 notiCycle을 갱신
    private func setupPartyService() {
        
        guard let party = partys.lastParty else {
            print("현재 진행 중인 파티가 없습니다.")
            return
        }
        
        let currentStartDate = party.startDate
        let currentNotiCycle = NotiCycle(rawValue: party.notiCycle) ?? .min30
        
        PartyService.shared.setPartyService(startDate: currentStartDate, notiCycle: currentNotiCycle)
    }
}
