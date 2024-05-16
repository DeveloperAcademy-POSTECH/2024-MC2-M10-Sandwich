//
//  ActionButton.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/15/24.
//

import SwiftUI

/// 특정 액션을 위한 커스텀 버튼
struct ActionButton: View {
    
    /// 버튼 타입(종류) 열거형
    enum ButtonType {
        case primary
        case secondary
        case disabled
    }
    
    /// 버튼 타이틀
    let title: String
    
    /// 버튼 타입
    let buttonType: ButtonType
    
    /// 버튼 Tap 액션
    let tapAction: () -> Void
    
    /// 배경색상 결정 로직
    private var backgroundColor: Color {
        switch buttonType {
        case .primary: return .shotGreen
        case .secondary: return .shotD8
        case .disabled: return .shot1C
        }
    }
    
    /// 글자 색상 결정 로직
    private var titleColor: Color {
        switch buttonType {
        case .primary, .secondary: return .shot00
        case .disabled: return .shot33
        }
    }
    
    var body: some View {
        Button {
            tapAction()
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(backgroundColor)
                .foregroundStyle(titleColor)
                .pretendard(.semiBold, 17)
                .clipShape(RoundedRectangle(cornerRadius: 11))
        }
    }
}

#Preview {
    ZStack {
        Color(.shot00)
            .ignoresSafeArea()
        
        HStack(spacing: 8) {
            ActionButton(
                title: "더 마시기",
                buttonType: .secondary
            ) {}
            
            ActionButton(
                title: "끝내기",
                buttonType: .primary
            ) {}
            
            ActionButton(
                title: "비활성화",
                buttonType: .disabled
            ) {}
        }
        .padding(.horizontal, 16)
    }
}
