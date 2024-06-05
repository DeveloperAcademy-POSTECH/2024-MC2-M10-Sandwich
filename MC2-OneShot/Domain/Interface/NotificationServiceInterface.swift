//
//  NotificationServiceInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/5/24.
//

import Foundation

/// Domain - Notification 서비스 인터페이스
protocol NotificationServiceInterface {
    func requestPermission()
    func scheduleFunction(date: Date, handler: @escaping () -> Void)
    func scheduleNotification(date: Date, title: String, subtitle: String)
    func cancelAllPendingFunction()
    func cancelAllPendingNotification()
}
