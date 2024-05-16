//
//  ShutdownPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct ShutdownPopupView: View {
    @State var content: String = ""
    
    @Binding var isHelpMessagePresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(width: 361, height: 334)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundStyle(.shot25).opacity(0.95)
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "questionmark.circle")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                        
                        Text("자동 술자리 종료")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                        
                        Spacer()
                        
                        Button(action: {
                            isHelpMessagePresented.toggle()
                        }, label: {
                            ZStack {
                                Circle()
                                    .frame(width: 30, height: 30)
                                    .foregroundStyle(.shotC6)
                                Image(systemName: "xmark")
                                    .pretendard(.semiBold, 16)
                                    .foregroundStyle(.shot25)
                            }
                        })
                        
                    }
                    
                    ZStack {
                        Image(.imgLogo)
                            .resizable()
                            .frame(width: 225, height: 225).opacity(0.1)
                        
                        Rectangle()
                            .frame(width: 331, height: 264)
                            .foregroundStyle(.shot1C).opacity(0.6)
                            .padding(.top, 6)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                
                        Text("진행 되어있는  스탭을 기준으로 바로 다음 스탭이 일정 시간동안 완료되지 않아 술자리가 끝난 것 같아 종료했어요 ㅎㅎ! 님 또 취한듯 ㅋ.")
                            .foregroundColor(.shotFF)
                            .pretendard(.bold, 16)
                            .lineSpacing(20)
                            .padding()
                            
                        
                                
                            
                            
                        
                        
                    }
                }
                .padding(.horizontal, 16)
            }
            
        }
        .padding(16)
    }
}

#Preview {
    ShutdownPopupView( isHelpMessagePresented: .constant(true))
}
