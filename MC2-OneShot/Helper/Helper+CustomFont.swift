//
//  Helper+CustomFont.swift
//  MC2-OneShot
//
//  Created by Chang Jonghyeon on 5/14/24.
//

import SwiftUI

struct PretendardModifier: ViewModifier {
    
    /// 프리텐다드 폰트 이름 열거형
    enum FontWeight: String {
        case thin = "Pretendard-Thin"
        case extraLight = "Pretendard-ExtraLight"
        case light = "Pretendard-Light"
        case regular = "Pretendard-Regular"
        case medium = "Pretendard-Medium"
        case semiBold = "Pretendard-SemiBold"
        case bold = "Pretendard-Bold"
        case extraBold = "Pretendard-ExtraBold"
        case black = "Pretendard-Black"
    }
    
    var weight: FontWeight
    var size: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.custom(weight.rawValue, size: size))
    }
}

extension View {
    
    /// 프리텐다드 커스텀 폰트를 적용 후 반환합니다.
    func pretendard(_ weight: PretendardModifier.FontWeight, _ size: CGFloat) -> some View {
        modifier(PretendardModifier(weight: weight, size: size))
    }
}
