//
//  LifeCycleManager.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/17/24.
//

import Foundation
import SwiftUI
import Combine

final class LifeCycleManager {
    
    typealias LifeCyclePublisher = AnyPublisher<NotificationCenter.Publisher.Output, NotificationCenter.Publisher.Failure>
    
    /// Subscription 해제를 위한 cacellables
    private var cancellables = Set<AnyCancellable>()
    
    deinit { print("LifeCycleManager 해제") }
}

// MARK: - LifeCycle Publisher
extension LifeCycleManager {
    
    /// LifeCycle Event를 포함한 Publisher를 반환합니다.
    private func lifeCyclePublisher(for event: LifeCycleEvent) -> LifeCyclePublisher {
        return NotificationCenter.default
            .publisher(for: event.notificationName)
            .eraseToAnyPublisher()
    }
    
    /// LifeCycle 전체 이벤트를 Merge 후 Publisher로 반환합니다.
    func mergeLifeCyclePublishers() -> LifeCyclePublisher {
        return Publishers.MergeMany(
            lifeCyclePublisher(for: .foreground),
            lifeCyclePublisher(for: .background),
            lifeCyclePublisher(for: .activce),
            lifeCyclePublisher(for: .terminate)
        )
        .eraseToAnyPublisher()
    }
}

// MARK: - LifeCycle Event
extension LifeCycleManager {
    
    /// APP LifeCycle 이벤트 열거형
    enum LifeCycleEvent {
        case activce
        case foreground
        case background
        case terminate
        
        /// Notification Name 반환 계산 속성
        var notificationName: Notification.Name {
            switch self {
            case .activce:
                return UIApplication.didBecomeActiveNotification
            case .foreground:
                return UIApplication.willEnterForegroundNotification
            case .background:
                return UIApplication.didEnterBackgroundNotification
            case .terminate:
                return UIApplication.willTerminateNotification
            }
        }
    }
}
