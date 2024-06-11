//
//  NotificationService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/5/24.
//

import UIKit
import UserNotifications

// MARK: - NotificationServiceInterface

final class NotificationService: NotificationServiceInterface {
    
    /// 함수 예약을 위한 타이머
    var timers: [Timer] = []
}

// MARK: - Protocol Implementation

extension NotificationService {
    
    /// Notiication 권한을 요청합니다.
    func requestPermission() {
        let options: UNAuthorizationOptions = [.alert, .sound]
        UNUserNotificationCenter.current()
            .requestAuthorization(options: options) { (success, error) in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
    }
    
    /// 지정된 Date에 실행될 함수를 예약합니다.
    func scheduleFunction(date: Date, handler: @escaping () -> Void) {
        let timerInterval = date.timeIntervalSinceNow
        if timerInterval > 0 {
            let timer = Timer(fire: date, interval: 0, repeats: false) { _ in
                handler()
            }
            RunLoop.main.add(timer, forMode: .common)
            timers.append(timer)
        } else {
            print("Error: 과거 Date 시점의 예약은 불가합니다.")
        }
    }
    
    /// 지정된 Date에 실행될 Notification을 예약합니다.
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
    
    /// 예약되어있는 모든 함수를 취소합니다.
    func cancelAllPendingFunction() {
        for timer in timers { timer.invalidate() }
        timers.removeAll()
    }
    
    /// 예약되어있는 모든 Notification을 취소합니다.
    func cancelAllPendingNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    /// 앱 Badge를 초기화합니다.
    func resetBadge() {
        UNUserNotificationCenter.current()
            .setBadgeCount(0)
    }
}
