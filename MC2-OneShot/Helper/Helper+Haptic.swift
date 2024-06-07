//
//  Helper+Haptic.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/7/24.
//

import UIKit

final class HapticManager {
    static let shared = HapticManager()
    private init() {}
    
    /// Notification과 관련된 시스템 Haptic을 출력합니다.
    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }
    
    /// Impact에 따른 Haptic을 출력합니다.
    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }
}
