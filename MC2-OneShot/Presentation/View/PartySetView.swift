//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - PartySetView

struct PartySetView: View {
    
    @Environment(PartyUseCase.self) private var partyPlayUseCase
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    @State private var titleText: String = ""
    @State private var notiCycle: NotiCycle = NotiCycle.allCases.first ?? .min30
    @State private var membersInfo: [Member] = []
    
    @Binding private(set) var isPartySetViewPresented: Bool
    
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
    private func goStep() {
        
        HapticManager.shared.notification(type: .success)
        
        let today = Date.now
        
        // 1. SetView 가리기
        isPartySetViewPresented = false
        
        // 2. 영구 저장 데이터에 새로운 파티 데이터 생성
        partyPlayUseCase.startParty(
            Party(
                title: titleText,
                startDate: today,
                notiCycle: notiCycle.rawValue,
                memberList: membersInfo
            )
        )
        
        // 3. 파티 서비스 시작
        PartyService.shared.startParty(
            startDate: today,
            notiCycle: notiCycle
        )
    }
}

// MARK: - TitleView

private struct TitleView: View {
    
    @Binding private(set) var titleText: String
    
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
    
    @Binding private(set) var membersInfo: [Member]
    
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible()), count: 4)
    
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
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        }
                    }
                    
                    // + 버튼을 조건부로 표시
                    if membersInfo.count < 8 {
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
                            MemberCameraView(
                                isCameraViewPresented: $isCameraViewPresented,
                                membersInfo: $membersInfo
                            )
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        } footer: {
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
    
    @Binding private(set) var notiCycle: NotiCycle
    
    var body: some View {
        Section {
            HStack {
                Text("알람 주기")
                
                Spacer()
                
                Menu {
                    ForEach(NotiCycle.allCases, id: \.rawValue) { notiCycle in
                        Button("\(notiCycle.rawValue)분") { self.notiCycle = notiCycle }
                    }
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
                    
                    Text("무음모드를 해제해 주세요!")
                        .pretendard(.regular, 12)
                }
            }
        }
        .padding(4)
        .onAppear(perform : UIApplication.shared.hideKeyboard)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PartySetView(
        isPartySetViewPresented: .constant(true)
    )
    .modelContainer(MockModelContainer.mockModelContainer)
}
#endif
