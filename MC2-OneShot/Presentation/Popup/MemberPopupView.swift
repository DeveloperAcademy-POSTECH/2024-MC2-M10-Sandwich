//
//  MemberPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct MemberPopupView: View {
    var party: Party = Party(
        title: "포항공대애애앵",
        startDate: Date(),
        notiCycle: 30,
        memberList: [
            Member(profileImageData: Data()),
            Member(profileImageData: Data()),
            Member(profileImageData: Data()),
            Member(profileImageData: Data()),
            Member(profileImageData: Data()),
            Member(profileImageData: Data()),
            Member(profileImageData: Data())
        ]
    )
    
    let columns: [GridItem] = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    @Binding var isMemberPopupPresented: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Rectangle()
                    .frame(width: 361, height: 334)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .foregroundStyle(.shot25).opacity(0.95)
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "person.fill")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 17)
                            .foregroundStyle(.shotFF)
                        
                        Spacer()
                        
                        Button(action: {
                            isMemberPopupPresented.toggle()
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
                    
                    ZStack(alignment: .top) {
                        Image(.imgLogo)
                            .resizable()
                            .frame(width: 225, height: 225).opacity(0.1)
                            .padding(.top, 33)
                            .padding(.bottom, 12)
                        
                        LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(party.memberList.indices, id: \.self) { index in
                                    PeopleCell(member: party.memberList[index])
                                }
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

struct PeopleCell: View {
    var member: Member
    
    var body: some View {
        Circle()
            .frame(width: 60, height: 60)
    }
}

#Preview {
    MemberPopupView(isMemberPopupPresented: .constant(true))
}
