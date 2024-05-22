//
//  CommentPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct CommentPopupView: View {
    @Binding var isCommentPopupPresented: Bool
    @State var content: String = ""
    
    var party: Party
    
    init(isCommentPopupPresented: Binding<Bool>, party: Party) {
        self._isCommentPopupPresented = isCommentPopupPresented
        self._content = State(initialValue: party.comment ?? "")
        self.party = party
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(width: 361, height: 361)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundStyle(.shot25).opacity(0.95)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotGreen)
                        
                        Text("기억 남기기")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                    }
                    .padding(16)
                    
                    TextField(text: $content, axis: .vertical) {
                        Color.clear
                    }
                    .padding()
                    .frame(width: 329, height: 234, alignment: .topLeading)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.shot1C).opacity(0.6))
                    .foregroundStyle(.shotFF)
                    .pretendard(.regular, 16)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    
                    ActionButton(
                        title: "닫기",
                        buttonType: .popupfinish
                    ) {
                        party.comment = content
                        isCommentPopupPresented.toggle()
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                    .padding(.top, 8)
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(16)
        .onAppear (perform : UIApplication.shared.hideKeyboard)
    }
}
