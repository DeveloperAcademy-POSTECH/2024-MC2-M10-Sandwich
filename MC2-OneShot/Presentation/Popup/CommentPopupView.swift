//
//  CommentPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - CommentPopupView

struct CommentPopupView: View {
    
    @FocusState private var focusField: Field?
    
    @State private var content: String = ""
    
    @Binding var isCommentPopupPresented: Bool
    
    let party: Party
    
    enum Field: Hashable {
        case content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(symbol: .textBubble)
                    .pretendard(.semiBold, 15)
                    .foregroundStyle(.shotGreen)
                
                Text("기억 남기기")
                    .pretendard(.bold, 17)
                    .foregroundStyle(.shotFF)
            }
            .padding(.horizontal,16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            
            TextField("이곳을 클릭하여 술자리의 기억을 남겨주세요!", text: $content, axis: .vertical)
                .frame(maxWidth: .infinity)
                .frame(height: 240, alignment: .topLeading)
                .padding(16)
                .background(RoundedRectangle(cornerRadius: 10).foregroundStyle(.shot1E))
                .foregroundStyle(.shotFF)
                .padding(.horizontal, 16)
                .pretendard(.regular, 16)
                .multilineTextAlignment(.leading)
                .focused($focusField, equals: .content)
                .onTapGesture { focusField = .content }
            
            ActionButton(
                title: "닫기",
                buttonType: .popupfinish
            ) {
                party.comment = content
                isCommentPopupPresented.toggle()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
            .padding(.top, 16)
        }
        .background(RoundedRectangle(cornerRadius: 16).foregroundStyle(.shot25))
        .padding(.horizontal, 16)
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    struct Container: View {
        var body: some View {
            CommentPopupView(
                isCommentPopupPresented: .constant(true),
                party: Party(
                    title: "포항공대대애앵앵",
                    startDate: .now,
                    notiCycle: 60,
                    memberList: []
                )
            )
        }
    }
    
    return Container()
        .modelContainer(ModelContainerCoordinator.mock)
}
#endif
