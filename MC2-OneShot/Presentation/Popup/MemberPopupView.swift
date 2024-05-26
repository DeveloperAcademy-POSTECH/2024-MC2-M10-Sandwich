//
//  MemberPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct MemberPopupView: View {

    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @Binding var isMemberPopupPresented: Bool
    
    var memberList: [Member]
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: 361, height: 320)
                    .foregroundStyle(.shot25)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Image(systemName: "person.fill")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    
                    ZStack(alignment: .top) {
                        Image(.imgLogo)
                            .resizable()
                            .frame(width: 225, height: 225).opacity(0.1)
                            .padding(.top, 33)
                            .padding(.bottom, 12)
                        
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
                            .padding(.bottom, 30)
                            .frame(width: 329, height: 150, alignment: .top)
                            
                            ActionButton(
                                title: "닫기",
                                buttonType: .popupfinish
                            ) {
                                isMemberPopupPresented.toggle()
                            }
                            .frame(width: 329, height: 50)
                            .padding(.top, 30)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 16)
                        }
                        .padding(.top, 30)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(16)
    }
}


#Preview {
    MemberPopupView(isMemberPopupPresented: .constant(true), memberList: [])
}
