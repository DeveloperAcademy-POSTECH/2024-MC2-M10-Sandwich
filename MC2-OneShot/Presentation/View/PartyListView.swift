//
//  PartyListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - PartyListView

struct PartyListView: View {
    
    let party: Party
    
    var body: some View {
        VStack(spacing: 0) {
            HeaderView(party: party)
            Divider()
            StepListView(party: party)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if party.isLive { FinishPartyButton(party: party) }
                else { CommentButton(party: party) }
            }
        }
    }
}

// MARK: - HeaderView

private struct HeaderView: View {
    
    @State private var isMemberPopupPresented = false
    
    let party: Party
    
    var body: some View {
        HStack {
            Text(party.title)
                .pretendard(.bold, 25)
                .foregroundStyle(.shotFF)
            
            Spacer()
            
            Button {
                isMemberPopupPresented.toggle()
            } label: {
                MemberInfoView(party: party)
            }
            .disabled(party.memberList.isEmpty)
        }
        .padding(.top, 3)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
        .fullScreenCover(isPresented: $isMemberPopupPresented) {
            MemberPopupView(
                isMemberPopupPresented: $isMemberPopupPresented,
                memberList: party.memberList
            )
            .foregroundStyle(.shotFF)
            .presentationBackground(.black.opacity(0.7))
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - MemberInfoView

private struct MemberInfoView: View {
    
    let party: Party
    
    var body: some View {
        ZStack(alignment: .trailing) {
            if (0...3).contains(party.memberList.count) {
                ForEach(party.memberList.indices, id: \.self) { index in
                    if let image = UIImage(data: party.memberList[index].profileImageData) {
                        Image(uiImage: image)
                            .resizable()
                            .frame (width: 32, height: 32)
                            .clipShape(Circle())
                            .padding(.trailing, 24*CGFloat(index))
                    }
                }
            } else {
                ForEach(0..<2) { index in
                    if let image = UIImage(data: party.memberList[index].profileImageData) {
                        Image(uiImage: image)
                            .resizable()
                            .frame (width: 32, height: 32)
                            .clipShape(Circle())
                            .padding(.trailing, 24*CGFloat(index))
                    }
                }
                
                ZStack {
                    Circle()
                        .frame(width: 32)
                        .foregroundStyle(.shot00)
                    
                    Text("+\(party.memberList.count - 2)")
                        .pretendard(.semiBold, 17)
                        .foregroundStyle(.shotC6)
                }
                .padding(.trailing, 24 * 2)
            }
        }
    }
}

// MARK: - FinishPartyButton

private struct FinishPartyButton: View {
    
    @State private var isFinishPopupPresented = false
    
    let party: Party
    
    var body: some View {
        Button {
            HapticManager.shared.notification(type: .warning)
            isFinishPopupPresented = true
        } label: {
            Text("술자리 종료")
                .pretendard(.semiBold, 16)
                .foregroundStyle(.shotGreen)
        }
        .fullScreenCover(isPresented: $isFinishPopupPresented) {
            FinishPopupView(memberList: party.memberList)
                .foregroundStyle(.shotFF)
                .presentationBackground(.black.opacity(0.7))
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - CommentButton

private struct CommentButton: View {
    
    @State private var isCommentPopupPresented = false
    
    let party: Party
    
    var body: some View {
        Button {
            isCommentPopupPresented = true
        } label: {
            Image(symbol: .textBubble)
                .pretendard(.semiBold, 15)
                .foregroundStyle(.shotGreen)
        }
        .fullScreenCover(isPresented: $isCommentPopupPresented) {
            CommentPopupView(
                isCommentPopupPresented: $isCommentPopupPresented,
                party: party
            )
            .foregroundStyle(.shotFF)
            .presentationBackground(.black.opacity(0.7))
        }
        .transaction { $0.disablesAnimations = true }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    struct Container: View {
        var body: some View {
            PartyListView(
                party: Party(
                    title: "포항공대대애앵앵",
                    startDate: .now,
                    notiCycle: 60,
                    memberList: []
                )
            )
        }
    }
    
    return Container()
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
