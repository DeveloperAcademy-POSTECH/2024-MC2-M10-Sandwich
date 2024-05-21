//
//  NotificationManager.swift
//  MC2-OneShot
//
//  Created by KimYuBin on 5/17/24.
//

import SwiftUI
import UserNotifications

class NotificationManager {
    static let instance = NotificationManager()
    private init() {}
    
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
    
    func scheduleNotification(date: Date, title: String, subtitle: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = subtitle
        
        let soundName = "CustomSound"
        let soundExtension = "mp3"
        
        if let soundURL = Bundle.main.url(forResource: soundName, withExtension: soundExtension) {
            let sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName + "." + soundExtension))
            content.sound = sound
        } else {
            print("사운드 파일을 찾을 수 없습니다.")
        }
        
        content.badge = 1
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        print("type: ", type(of: dateComponents))
        print("dateComponents: ", dateComponents)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 삭제
    }
}
