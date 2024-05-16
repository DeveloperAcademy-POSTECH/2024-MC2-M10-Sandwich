//
//  FinishPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct FinishPopupView: View {
    var body: some View {
        VStack {
            ZStack {
                Rectangle()
                    .frame(width: 361, height: 361)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundStyle(.shot25).opacity(0.95)
                
                VStack(spacing: 0) {
                    Circle()
                        .frame(width: 118, height: 118)
                        .foregroundStyle(.clear)
                        .overlay(
                            Circle()
                                .stroke(.shotGreen, lineWidth: 5)
                        )
                    
                    Text("술자리를 정말로 끝낼까요?")
                        .pretendard(.semiBold, 17)
                        .padding(.top, 19)
                    
                    Text("진짜루? 진쨔류? 진짤루?!")
                        .pretendard(.semiBold, 14)
                        .foregroundStyle(.shot7B)
                        .padding(.top, 6)
                    
                    HStack(spacing: 8) {
                        ActionButton(
                            title: "더 마시기",
                            buttonType: .secondary
                        ) {}
                        
                        ActionButton(
                            title: "끝내기",
                            buttonType: .primary
                        ) {}
                    }
                    .padding(.horizontal, 33)
                    .padding(.top, 50)   
                }
            }
            
        }
    }
}

#Preview {
    FinishPopupView()
}
