//
//  FinishPopupView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - FinishPopupView

struct FinishPopupView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(\.dismiss) private var dismiss
    
    var memberList: [Member]
    
    var body: some View {
        
        VStack(spacing: 0) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundStyle(.shot25)
                    .frame(
                        width: min(
                            ScreenSize.screenWidth,
                            ScreenSize.screenHeigh
                        ) * 0.9,
                        height: min(
                            ScreenSize.screenWidth,
                            ScreenSize.screenHeigh
                        ) * 0.9
                    )
                    .padding()
                
                VStack(spacing: 0) {
                    if memberList.isEmpty {
                        Image(.dummyProfile)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 118, height: 118)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.shotGreen, lineWidth: 5)
                            )
                            .padding(.top, 40)
                        
                    } else {
                        if let randomMember = memberList.randomElement(),
                           let image = UIImage(data: randomMember.profileImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 118, height: 118)
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(.shotGreen, lineWidth: 5)
                                )
                                .padding(.top, 40)
                        }
                    }
                    
                    Text(
                        partyUseCase.state.isPartyShutdown
                        ? "술자리 파티를 정리할까요?"
                        : "술자리를 정말로 끝낼까요?"
                    )
                    .pretendard(.semiBold, 17)
                    .foregroundStyle(.shotFF)
                    .padding(.top, 20)
                    
                    Text(
                        partyUseCase.state.isPartyShutdown
                        ? "취했으면 어쩔수 없는거죠!"
                        : "진짜루? 진쨔류? 진짤루?!"
                    )
                    .pretendard(.semiBold, 14)
                    .foregroundStyle(.shot7B)
                    .padding(.top, 6)
                    
                    HStack(spacing: 8) {
                        ActionButton(
                            title: partyUseCase.state.isPartyShutdown ? "취소" : "더 마시기",
                            buttonType: .secondary
                        ) {
                            dismiss()
                        }
                        
                        ActionButton(
                            title: partyUseCase.state.isPartyShutdown ? "정리하기" : "끝내기",
                            buttonType: .primary
                        ) {
                            UIView.setAnimationsEnabled(false)
                            dismiss()
                            HapticManager.shared.notification(type: .success)
                            partyUseCase.finishParty()
                        }
                    }
                    .padding(.horizontal, 33)
                    .padding(.top, 50)
                }
            }
        }
        .onDisappear {
            UIView.setAnimationsEnabled(true)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    FinishPopupView(memberList: [])
        .environment(
            PartyUseCase(
                dataService: PersistentDataService(modelContext: ModelContainerCoordinator.mock.mainContext),
                notificationService: NotificationService()
            )
        )
}
#endif
