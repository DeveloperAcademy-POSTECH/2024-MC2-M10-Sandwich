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
        //        VStack(spacing: 0) {
        ZStack(alignment: .center) {
            Rectangle()
                .frame(width: 364, height: 244)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .foregroundStyle(.shot25).opacity(0.95)
                .overlay{
                    VStack(spacing: 0) {
                        HStack{
                            Image(systemName: "exclamationmark.circle")
                                .pretendard(.semiBold, 17)
                                .foregroundStyle(.shotFF)
                            
                            Text("자동 술자리 종료")
                                .pretendard(.bold, 17)
                                .foregroundStyle(.shotFF)
                            
                            Spacer()
                        }
                        .padding(.top, 16)
                        .padding(.bottom,12)
                        
                        Divider()
                        
                        
                        Text("바로 다음 스탭이 일정 시간동안 완료되지 않아 술자리가 끝난 것 같아 종료했어요 ㅎㅎ!")
                        
                            .foregroundColor(.shotFF)
                            .pretendard(.regular, 16)
                            .lineSpacing(10)
                           
                            .padding(.bottom, 56)
                            .padding(.top, 10)
                        
                        
                        
                        Spacer()
                        
                        ActionButton(
                            title: "확인",
                            buttonType: .popupfinish
                        ) {
                            isHelpMessagePresented.toggle()
                        }
                        Spacer()
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
