//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartySetView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    @EnvironmentObject private var persistentDataManager: PersistentDataManager
    
    @State private var titleText: String = ""
    @State private var notiCycle: NotiCycle = .min30
    
    @Binding var isPartySetViewPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
                .frame(height: 30)
            
            Text("술자리 생성하기")
                .pretendard(.semiBold, 17)
                .foregroundStyle(.shotFF)
            
            List {
                TextField("제목", text: $titleText)
               
                // 위치 변경
                NotiCycleView(notiCycle: $notiCycle)
                MemberListView()
            }
            
            Spacer()
            
            ActionButton(
                title: "술자리 시작하기",
                buttonType: titleText.isEmpty
                ? .disabled : .primary
            ) {
                goStep()
            }
            .padding(16)
        }
    }
    
    /// GO STEP! 버튼 클릭 시 호출되는 함수입니다.
    func goStep() {
        
        let today = Date.now
        
        // 1. 영구 저장 데이터에 새로운 파티 데이터 생성
        persistentDataManager.createParty(
            title: titleText,
            startDate: today,
            notiCycle: notiCycle
        )
        
        // 2. 파티 서비스 시작
        PartyService.shared.startParty(
            startDate: today,
            notiCycle: notiCycle
        )
        
        // 3. 화면 띄우기
        isPartySetViewPresented = false
    }
}

// MARK: - MemberListView
private struct MemberListView: View {
    
    /// 멤버 버튼 타입 정의를 위한 열거형
    enum MemberForm: Hashable {
        case member(name: String)
        case add
    }
    
    /// 멤버 더미데이터
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
    
    /// 멤버 버튼 생성을 위한 계산 속성
    var memberButtons: [MemberForm] {
        var memberArray = memberForms
        memberArray.append(.add)
        return memberArray
    }
    
    var body: some View {
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
                        
                        // 버튼이 Add일경우
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
                                    // plus color 변경
                                        .foregroundStyle(.shot6D)
                                }
                            }
                        }
                        
                        // 멤버 이미지일 경우
                        else {
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
    }
}

// MARK: - NotiCycleView
private struct NotiCycleView: View {
    
    @Binding var notiCycle: NotiCycle
    
    var body: some View {
        Section {
            HStack {
                Text("알람 주기")
                
                Spacer()
                
                Menu {
                    Button("30분") { notiCycle = .min30 }
                    Button("60분") { notiCycle = .min60 }
                    Button("90분") {notiCycle = .min90 }
                    Button("120분") { notiCycle = .min120 }
                } label: {
                    HStack {
                        Text("\(notiCycle.rawValue)분")
                            .pretendard(.regular, 17)
                        
                        Image(systemName: "chevron.up.chevron.down")
                    }
                    .foregroundStyle(.shotFF).opacity(0.6)
                }
            }
        } footer: {
            
            // 인포 문구 추가
            VStack(alignment: .leading){
                HStack{
                    Image(systemName: "questionmark.circle")
                    Text("알림 주기마다 PUSH 알림을 보내드려요.")
                        .pretendard(.regular, 14)
                }
                
                HStack{
                    Image(systemName: "exclamationmark.circle")
                    Text("무음모드를 해제해주세요!")
                        .pretendard(.regular, 14)
                }
            }
            
        }
    }
}

#Preview {
    PartySetView(
        isPartySetViewPresented: .constant(true)
    )
    .modelContainer(MockModelContainer.mockModelContainer)
}
