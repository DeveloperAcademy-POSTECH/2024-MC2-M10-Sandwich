//
//  AppDelegate.swift
//  MC2-OneShot
//
//  Created by KimYuBin on 5/20/24.
//

import SwiftUI
import UserNotifications
import AVFoundation

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // Foreground(앱이 켜진 상태)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner])
        
        print("알림 표시")
        playSound()
    }
    
    // 사용자가 알림을 탭하여 앱을 열 때 호출되는 메서드
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    var audioPlayer: AVAudioPlayer?
    
    private func playSound() {
        let soundName = "CustomSound"
        let soundExtension = "mp3"
        
        guard let url = Bundle.main.url(forResource: soundName, withExtension: soundExtension) else {
            print("사운드 파일을 찾을 수 없습니다.")
            return
        }
        
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            print("재생됨")
        } catch {
            print("Failed to play sound: \(error.localizedDescription)")
        }
    }
}
