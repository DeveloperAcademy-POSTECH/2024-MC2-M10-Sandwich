//
//  Helper+SFSymbol.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/5/24.
//

import SwiftUI

extension Image {
    
    /// SFSymbol을 생성합니다.
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}

enum SFSymbol: String {
    
    /// 플러스
    case plus = "plus"
    
    /// 아래쪽 화살표
    case chevronDown = "chevron.down"
    
    /// 오른쪽 화살표
    case chevronRight = "chevron.right"
    
    /// 왼쪽 화살표
    case chevronLeft = "chevron.left"
    
    /// 위 아래 화살표
    case chevronUpDown = "chevron.up.chevron.down"
    
    /// 오른쪽 위 대각선 화살표
    case arrowUpForward = "arrow.up.forward"
    
    /// 돋보기
    case magnifyingglass = "magnifyingglass"
    
    /// 사람
    case person = "person.fill"
    
    /// 체크 표시
    case checkmark = "checkmark"
    
    /// 물음표 동그라미
    case questionmarkCircle = "questionmark.circle.fill"
    
    /// 느낌표 동그라미
    case exclamationmarkCircle = "exclamationmark.circle.fill"
    
    /// 카메라 동그라미
    case cameraCircle = "camera.circle.fill"
    
    /// 전면 후면 전환
    case frontBackToggle = "arrow.triangle.2.circlepath"
    
    /// 플래시 ON
    case bolt = "bolt"
    
    /// 플래시 OFF
    case boltSlash = "bolt.slash"
    
    /// 말풍선
    case textBubble = "text.bubble.fill"
    
    /// 저장하기
    case squareArrowDown = "square.and.arrow.down"
}
