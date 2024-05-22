//
//  FinishPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct FinishPopupView: View {
    
    @Binding var isFinishPopupPresented: Bool
    @Binding var isPartyEnd: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: 361, height: 361)
                    .foregroundStyle(.shot25)
                
                VStack(spacing: 0) {
                    // TODO: 함께한 사람들 이미지중 랜덤으로 들어오도록 수정
                    Image(.dummyProfile)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 118, height: 118)
                        .cornerRadius(50)
                        .overlay(
                            Circle()
                                .stroke(.shotGreen, lineWidth: 5)
                        )
                        .padding(.top, 40)
                    
                    Text("술자리를 정말로 끝낼까요?")
                        .pretendard(.semiBold, 17)
                        .foregroundStyle(.shotFF)
                        .padding(.top, 20)
                    
                    Text("진짜루? 진쨔류? 진짤루?!")
                        .pretendard(.semiBold, 14)
                        .foregroundStyle(.shot7B)
                        .padding(.top, 6)
                    
                    HStack(spacing: 8) {
                        ActionButton(
                            title: "더 마시기",
                            buttonType: .secondary
                        ) {
                            isFinishPopupPresented.toggle()
                        }
                        
                        ActionButton(
                            title: "끝내기",
                            buttonType: .primary
                        ) {
                            PartyService.shared.endParty()
                            isFinishPopupPresented = false
                            isPartyEnd = true
                        }
                    }
                    .padding(.horizontal, 33)
                    .padding(.top, 50)   
                }
            }
        }
    }
}

#Preview {
    FinishPopupView(
        isFinishPopupPresented: .constant(true),
        isPartyEnd: .constant(false)
    )
}
