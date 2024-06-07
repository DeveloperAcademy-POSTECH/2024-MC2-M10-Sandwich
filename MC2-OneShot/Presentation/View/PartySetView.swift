//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - PartySetView

struct PartySetView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(\.dismiss) private var dismiss
    
    @State private var titleText: String = ""
    @State private var notiCycle: NotiCycle = NotiCycle.allCases.first ?? .min30
    
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
                MemberListView()
            }
            
            Spacer()
            
            ActionButton(
                title: "술자리 시작하기",
                buttonType: titleText.isEmpty
                ? .disabled : .primary
            ) {
                dismiss()
                partyUseCase.startParty(
                    Party(
                        title: titleText,
                        startDate: .now,
                        notiCycle: notiCycle.rawValue,
                        memberList: partyUseCase.members
                    )
                )
            }
            .padding(16)
        }
        .onDisappear { partyUseCase.resetPartySetting() }
    }
}

// MARK: - TitleView

private struct TitleView: View {
    
    @Binding private(set) var titleText: String
    
    var body: some View {
        Section {
            TextField("제목", text: $titleText)
                .onChange(of: titleText) { _, text in
                    if text.count > 12 { titleText.removeLast() }
                }
        } footer: {
            HStack{
                Image(symbol: .exclamationmarkCircle)
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

// MARK: - NotiCycleView

private struct NotiCycleView: View {
    
    @Binding private(set) var notiCycle: NotiCycle
    
    var body: some View {
        Section {
            HStack {
                Text("알람 주기")
                    .pretendard(.regular, 17)
                    .foregroundStyle(.shotFF)
                
                Spacer()
                
                Menu {
                    ForEach(NotiCycle.allCases, id: \.rawValue) { notiCycle in
                        Button("\(notiCycle.rawValue)분") { self.notiCycle = notiCycle }
                    }
                } label: {
                    HStack {
                        Text("\(notiCycle.rawValue)분")
                            .pretendard(.regular, 17)
                        
                        Image(symbol: .chevronUpDown)
                    }
                    .foregroundStyle(.shotFF).opacity(0.6)
                }
            }
        } footer: {
            VStack(alignment: .leading){
                HStack{
                    Image(symbol: .questionmarkCircle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                    
                    Text("알림 주기마다 PUSH 알림을 보내드려요.")
                        .pretendard(.regular, 12)
                }
                
                HStack{
                    Image(symbol: .exclamationmarkCircle)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 14, height: 14)
                    
                    Text("무음모드를 해제해 주세요!")
                        .pretendard(.regular, 12)
                }
            }
        }
        .padding(4)
        .onAppear { UIApplication.shared.hideKeyboard() }
    }
}

// MARK: - MemberListView

private struct MemberListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    
    @State private var isCameraViewPresented = false
    
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
                    ForEach(partyUseCase.members) { member in
                        if let image = UIImage(data: member.profileImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .frame(width: 60, height: 60)
                                .clipShape(Circle())
                        }
                    }
                    
                    if partyUseCase.members.count < 8 {
                        Button {
                            isCameraViewPresented.toggle()
                        } label: {
                            ZStack {
                                Circle()
                                    .frame(width: 60)
                                    .foregroundStyle(.shot33)
                                
                                Image(symbol: .plus)
                                    .resizable()
                                    .frame(width: 32, height: 32)
                                    .foregroundStyle(.shot6D)
                            }
                        }
                        .buttonStyle(BorderlessButtonStyle())
                        .fullScreenCover(isPresented: $isCameraViewPresented) {
                            MemberCameraView()
                        }
                    }
                }
                .padding(.bottom, 8)
            }
        } footer: {
            HStack {
                Image(symbol: .cameraCircle)
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

// MARK: - Preview

#if DEBUG
#Preview {
    PartySetView()
        .modelContainer(MockModelContainer.mock)
        .environment(
            PartyUseCase(
                dataService: PersistentDataService(
                    modelContext: MockModelContainer.mock.mainContext
                ),
                notificationService: NotificationService()
            )
        )
}
#endif
