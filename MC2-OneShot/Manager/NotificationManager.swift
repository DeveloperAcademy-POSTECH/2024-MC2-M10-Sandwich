//
//  NotificationManager.swift
//  MC2-OneShot
//
//  Created by KimYuBin on 5/17/24.
//

import SwiftUI
import UserNotifications
import CoreLocation

struct LocalPushNotification: View {
    let manager = NotificationManager.instance
    var body: some View {
        VStack(spacing: 40) {
            Button("알림 권한 설정") {
                manager.requestAuthorization()
            }
            Button("알림 예약") {
                manager.scheduleNotification(trigger: .calender)
            }
            Button("삭제") {
                manager.cancelNotification()
            }
        }
        .onAppear {
            UNUserNotificationCenter.current().setBadgeCount(0, withCompletionHandler: nil)
        }
    }
}

class NotificationManager {
    static let instance = NotificationManager()
    private init() {}
    
    // 알림 설정 허용 여부
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { (success, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("SUCCESS")
            }
        }
    }
    
    enum TriggerType: String {
        case calender = "calender"
        
        var trigger: UNNotificationTrigger {
            switch self {
            case .calender:
                let dateComponent = DateComponents(year: 2024, month: 5, day: 17, hour: 15, minute: 43)
                return UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
            }
        }
    }
    
    func scheduleNotification(trigger: TriggerType) {
        
        let content = UNMutableNotificationContent()
        content.title = "알림 주기가 다가왔습니다"
        content.subtitle = "사진을 찍어주세요!"
        
        let soundName = "customSound"
        let soundExtension = "mp3"
        
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: soundExtension) {
            let sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName + "." + soundExtension))
            content.sound = sound
        } else {
            print("사운드 파일을 찾을 수 없습니다.")
        }
        
        content.badge = 1
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger.trigger)
        UNUserNotificationCenter.current().add(request)
        
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 삭제
    }
}
