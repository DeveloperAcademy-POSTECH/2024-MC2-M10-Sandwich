//
//  CommentPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct CommentPopupView: View {
    
    @State var content: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(width: 361, height: 334)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundStyle(.shot25).opacity(0.95)
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotGreen)
                        
                        Text("기억 남기기")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                        
                        Spacer()
                        
                        Button(action: {
                            // 창 닫기 ToDo
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
                            .frame(width: 225, height: 225).opacity(0.1)
                        
                        Rectangle()
                            .frame(width: 331, height: 264)
                            .foregroundStyle(.shot1C).opacity(0.6)
                            .padding(.top, 6)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        
//                        TextEditor(text: $content)
//                            .foregroundColor(.white)
//                            .background(Color.clear)
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .frame(width: 331, height: 260)
//                            .pretendard(.semiBold, 17)
//                            .multilineTextAlignment(.leading)
//                            .padding(.top, 6)
                    }
                }
                .padding(.horizontal, 16)
            }
            
        }
        .padding(16)
    }
}

#Preview {
    CommentPopupView()
}
