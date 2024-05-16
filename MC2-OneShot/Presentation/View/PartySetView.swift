//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartySetView: View {
    
    @EnvironmentObject private var pathModel: PathModel
    
    @State private var titleText: String = ""
    @State private var notiCycle = 30
    
    @Binding var isPartySetViewPresented: Bool
    
    enum MemberForm: Hashable {
        case member(name: String)
        case add
    }
    
    let memberForms: [MemberForm] = [
        .member(name: "김민준"),
        .member(name: "오띵진"),
        .member(name: "정혜정"),
        .member(name: "김유빈"),
        .member(name: "장종현"),
        .member(name: "김여운"),
    ]
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var memberButtons: [MemberForm] {
        var memberArray = memberForms
        memberArray.append(.add)
        return memberArray
    }
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                Spacer()
                    .frame(height: 30)
                
                Text("술자리 만들기")
                    .pretendard(.semiBold, 17)
                    .foregroundStyle(.shotFF)
                
                List {
                    
                    // MARK: - 제목 입력
                    TextField("제목", text: $titleText)
                    
                    // MARK: - 사람 추가
                    Section {
                        VStack(alignment: .leading) {
                            Text("사람 추가")
                                .pretendard(.regular, 17)
                                .foregroundStyle(.shotFF)
                                .padding(.top, 6)
                            
                            Spacer()
                                .frame(height: 16)
                            
                            LazyVGrid(columns: columns, spacing: 30) {
                                ForEach(memberButtons, id: \.self) { member in
                                    if member == .add {
                                        Button {
                                         //카메라 연결
                                        } label: {
                                            ZStack{

                                                Circle()
                                                    .frame (width: 60)
                                                    .foregroundStyle(.shot33)
                                                Image(systemName: "plus")
                                                    .resizable()
                                                    .frame(width: 32, height: 32)
                                                    .foregroundStyle(.blue)
                                            }
                                        }
                                        
                                    } else {
                                        Image(.test)
                                            .resizable()
                                            .frame (width: 60, height: 60)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    } footer: {
                        Text("술자리를 함께하는 일행의 사진을 찍어봐요")
                            .pretendard(.regular, 14)
                    }
                    
                    // MARK: - 알람 주기
                    Section {
                        HStack {
                            Text("알람 주기")
                            
                            Spacer()
                            
                            Menu {
                                Button("30분") { notiCycle = 30 }
                                Button("60분") { notiCycle = 60 }
                                Button("90분") {notiCycle = 90 }
                                Button("120분") { notiCycle = 120 }
                            } label: {
                                HStack {
                                    Text("\(notiCycle)분")
                                        .pretendard(.regular, 17)
                                    
                                    Image(systemName: "chevron.up.chevron.down")
                                }
                                .foregroundStyle(.shotFF).opacity(0.6)
                            }
                        }
                    } footer: {
                        Text("알림 주기마다 PUSH 알림을 보내드려요")
                            .pretendard(.regular, 14)
                    }
                }
                
                Spacer()
                
                ActionButton(
                    title: "GO STEP!",
                    buttonType: titleText.isEmpty
                    ? .disabled : .primary
                ) {
                    // TODO: 술자리가 시작했다는 변수 업데이트
                    // TODO: 술자리 데이터 생성
                    isPartySetViewPresented.toggle()
                    pathModel.paths.append(.partyCamera)
                }
                .padding(16)
            }
        }
    }
}

#Preview {
    PartySetView(isPartySetViewPresented: .constant(true))
}
