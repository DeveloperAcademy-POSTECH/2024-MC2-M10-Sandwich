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
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 361, height: 361)
                    .foregroundStyle(.shot25)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "text.bubble.fill")
                            .pretendard(.semiBold, 15)
                            .foregroundStyle(.shotGreen)
                        
                        Text("기억 남기기")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                    }
//                    .padding(16)
                    .padding(.horizontal,16)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                    
                    TextField("이곳을 클릭하여 술자리의 기억을 남겨주세요!", text: $content, axis: .vertical)
                    .padding()
                    .frame(width: 329, height: 239, alignment: .topLeading)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .foregroundStyle(.shot1E))
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

#Preview {
    CommentPopupView(isCommentPopupPresented: .constant(true), party: Party(title: "포항공대대애앵앵", startDate: Date(), notiCycle: 60))
}
