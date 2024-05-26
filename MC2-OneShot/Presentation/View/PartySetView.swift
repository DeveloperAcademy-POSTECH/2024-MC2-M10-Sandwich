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
    @State private var notiCycle: NotiCycle = .min01
    @State var membersInfo: [Member] = []
    
    @Binding var isPartySetViewPresented: Bool
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer()
                .frame(height: 30)
            
            Text("술자리 생성하기")
                .pretendard(.semiBold, 17)
                .foregroundStyle(.shotFF)
            
            List {
                TitleView(titleText: $titleText)
                NotiCycleView(notiCycle: $notiCycle)
                MemberListView(membersInfo: $membersInfo)
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
        
        HapticManager.shared.notification(type: .success)
        
        let today = Date.now
        
        // 1. 영구 저장 데이터에 새로운 파티 데이터 생성
        persistentDataManager.createParty(
            title: titleText,
            startDate: today,
            notiCycle: notiCycle,
            memberList: membersInfo
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

// MARK: - TitleView
private struct TitleView: View {
    
    @Binding var titleText: String
    
    var body: some View {
        Section {
            TextField("제목", text: $titleText)
                .onChange(of: titleText) { _, text in
                    if text.count > 12 {
                        titleText.removeLast()
                    }
                }
        } footer: {
            HStack{
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text("제목은 12자 이내로 작성 가능해요.")
                    .pretendard(.regular, 12)
            }
        }
        .padding(4)
    }
}

// MARK: - MemberListView
private struct MemberListView: View {
    
    @State private var isCameraViewPresented = false
    @Binding var membersInfo: [Member]
    
    let columns: [GridItem] = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
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
                    ForEach(membersInfo, id: \.self) { member in
                        if let image = UIImage(data: member.profileImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .frame (width: 60, height: 60)
                                .clipShape(Circle())
                        }
                    }
                    
                    Button {
                        isCameraViewPresented.toggle()
                    } label: {
                        ZStack {
                            Circle()
                                .frame(width: 60)
                                .foregroundStyle(.shot33)
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.shot6D)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .fullScreenCover(isPresented: $isCameraViewPresented) {
                        MemberCameraView(isCameraViewPresented: $isCameraViewPresented, membersInfo: $membersInfo)
                    }
                }
                .padding(.bottom, 8)
                
                
            }
        } footer: {
            // footer 변경
            HStack {
                Image(systemName: "camera.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text("술자리를 함께하는 일행의 사진을 찍어봐요!")
                    .pretendard(.regular, 12)
            }
        }
        .padding(4)
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
                    Button("1분(테스트용)") { notiCycle = .min01 }
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
        }
        
    footer: {
        
        // 인포 문구 추가
        VStack(alignment: .leading){
            HStack{
                Image(systemName: "questionmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text("알림 주기마다 PUSH 알림을 보내드려요.")
                    .pretendard(.regular, 12)
            }
            
            HStack{
                Image(systemName: "exclamationmark.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 14, height: 14)
                Text("무음모드를 해제해주세요!")
                    .pretendard(.regular, 12)
            }
        }
    } .padding(4)
    }
}

#Preview {
    PartySetView(
        isPartySetViewPresented: .constant(true)
    )
    .modelContainer(MockModelContainer.mockModelContainer)
}
