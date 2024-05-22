//
//  AppDelegate.swift
//  MC2-OneShot
//
//  Created by KimYuBin on 5/21/24.
//

import Foundation

import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Foreground(앱이 켜진 상태)에서도 알림이 오도록 설정
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
}
