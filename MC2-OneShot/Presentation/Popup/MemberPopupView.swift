//
//  MemberPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - MemberPopupView

struct MemberPopupView: View {
    
    @Binding private(set) var isMemberPopupPresented: Bool
    
    let memberList: [Member]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 20), count: 4)
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 361, height: 319)
                    .foregroundStyle(.shot25)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(symbol: .person)
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                    }
                    .padding(.leading, 16)
                    
                    VStack(spacing: 0) {
                        LazyVGrid(columns: columns, spacing: 30) {
                            ForEach(memberList, id: \.self) { member in
                                if let image = UIImage(data: member.profileImageData) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .frame (width: 60, height: 60)
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .frame(width: 329, height: 150, alignment: .top)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 36)
                    .padding(.bottom, 30)
                    
                    ActionButton(
                        title: "닫기",
                        buttonType: .popupfinish
                    ) {
                        isMemberPopupPresented.toggle()
                    }
                    .frame(width: 329, height: 50)
                    .padding(.horizontal, 16)
                }
            }
        }
        .padding(16)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    MemberPopupView(isMemberPopupPresented: .constant(true), memberList: [])
}
#endif
