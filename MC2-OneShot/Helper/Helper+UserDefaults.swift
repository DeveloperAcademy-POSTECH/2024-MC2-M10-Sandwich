//
//  Helper+UserDefaults.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/20/24.
//

import Foundation

extension UserDefaults {
    
    /// 파티가 진행중인지 확인하는 Bool 값을 UserDefaults에서 반환합니다.
    var isPartyLive: Bool {
        return UserDefaults.standard.bool(forKey: Constant.isPartyLive)
    }
    
    /// 파티가 진행중인지 확인하는 UserDefaults 값을 업데이트합니다.
    func updatePartyLive(isLive: Bool) {
        UserDefaults.standard.set(isLive, forKey: Constant.isPartyLive)
    }
}
