//
//  Helper+PopToRootView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/6/24.
//

import UIKit

struct NavigationHelper {
    
    /// RootView로 이동합니다.
    static func popToRootView() {
        let keyWindow = UIApplication.shared.connectedScenes
            .filter({$0.activationState == .foregroundActive})
            .compactMap({$0 as? UIWindowScene})
            .first?.windows
            .filter({$0.isKeyWindow}).first
        findNavigationController(viewController: keyWindow?.rootViewController)?
            .popToRootViewController(animated: true)
    }
    
    private static func findNavigationController(viewController: UIViewController?) -> UINavigationController? {
        guard let viewController = viewController else {
            return nil
        }
        
        if let navigationController = viewController as? UINavigationController {
            return navigationController
        }
        
        for childViewController in viewController.children {
            return findNavigationController(viewController: childViewController)
        }
        
        return nil
    }
}
