//
//  ToastView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/6/24.
//

import SwiftUI

// MARK: - ToastView

struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .pretendard(.regular, 16)
            .foregroundStyle(.shotFF)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding(.top, 50)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ToastView(message: "토스트 뷰입니다!")
    }
}
#endif
