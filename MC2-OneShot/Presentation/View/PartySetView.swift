//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartySetView: View {
    @Binding var isPartySetViewPresented: Bool
    @EnvironmentObject private var pathModel: PathModel
    
    let rows = [
        GridItem(.flexible())
    ]
    
    let members : [String] = ["김민준","곽민준","오띵진","정혜정"]
    
    @State private var titleText: String = ""
    @State private var notiCycle = 30
    
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
                            Spacer()
                                .frame(height: 16)
                            
                            HStack(spacing: 24) {
                                ForEach(members, id: \.self) { member in
                                    Circle()
                                        .frame (width: 60)
                                }
                            }
                        }
                        .padding(10)
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
                
                ActionButton(title: "GO STEP!", buttonType: .primary) {
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
