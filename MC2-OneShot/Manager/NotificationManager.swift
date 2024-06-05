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
    
    var timers: [Timer] = []
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound]
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
        content.body = subtitle
        
        let soundName = "BBang"
        let soundExtension = "mp3"
        
        if let _ = Bundle.main.url(forResource: soundName, withExtension: soundExtension) {
            let sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: soundName + "." + soundExtension))
            content.sound = sound
        } else {
            print("사운드 파일을 찾을 수 없습니다.")
        }
        
        var calendar = Calendar.current
        calendar.locale = Locale(identifier: "ko_KR")
        
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        
        print("dateComponents: ", dateComponents)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 삭제
    }
    
    func scheduleFunction(date: Date, handler: @escaping () -> Void) {
        // 예약된 시간에 함수 실행
        let timerInterval = date.timeIntervalSinceNow
        if timerInterval > 0 {
            let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
                handler()
            }
            
            RunLoop.main.add(timer, forMode: .common)
            timers.append(timer)
        } else {
            print("The scheduled date is in the past.")
        }
    }
    
    func cancelFunction() {
        for timer in timers {
            timer.invalidate()
        }
        
        timers.removeAll()
    }
    
    func resetBadge() {
        DispatchQueue.main.async {
            UIApplication.shared.applicationIconBadgeNumber = 0
        }
    }
}
