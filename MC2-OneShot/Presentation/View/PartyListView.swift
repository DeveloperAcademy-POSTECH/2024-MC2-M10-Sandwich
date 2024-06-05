//
//  PartyListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import Photos

// MARK: - PartyListView

struct PartyListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(\.presentationMode) private var presentationMode
    
    @State private var isFinishPopupPresented = false
    @State private var isCommentPopupPresented = false
    @State private var isPartyResultViewPresented = false
    @State private var isPartyEnd = false
    
    let party: Party
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 0) {
                HeaderView(party: party)
                Divider()
                ScrollView {
                    ForEach(Array(party.stepList.enumerated()), id: \.offset) { index, step in
                        StepCell(index: index, step: step, startDate: party.startDate)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        if party.isLive {
                            Button(action: {
                                HapticManager.shared.notification(type: .warning)
                                isFinishPopupPresented = true
                            }, label: {
                                Text("술자리 종료")
                                    .pretendard(.semiBold, 16)
                                    .foregroundStyle(.shotGreen)
                            })
                            .fullScreenCover(isPresented: $isFinishPopupPresented, onDismiss: {
                                if isPartyEnd {
                                    isPartyResultViewPresented.toggle()
                                }
                            }, content: {
                                FinishPopupView(
                                    isFinishPopupPresented: $isFinishPopupPresented,
                                    memberList: party.memberList
                                )
                                .foregroundStyle(.shotFF)
                                .presentationBackground(.black.opacity(0.7))
                            })
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                        } else {
                            Button(action: {
                                isCommentPopupPresented = true
                            }, label: {
                                Image(symbol: .textBubble)
                                    .pretendard(.semiBold, 15)
                                    .foregroundStyle(.shotGreen)
                            })
                            .fullScreenCover(isPresented: $isCommentPopupPresented) {
//                                CommentPopupView(isCommentPopupPresented: $isCommentPopupPresented, party: party)
//                                    .foregroundStyle(.shotFF)
//                                    .presentationBackground(.black.opacity(0.7))
                            }
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $isPartyResultViewPresented) {
                    partyUseCase.presentCameraView(to: false)
                } content: {
                    PartyResultView()
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(symbol: .chevronLeft)
                            .foregroundStyle(.shotFF)
                    }
                }
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
                switch party.memberList.count {
                case 1...3:
                    ForEach(party.memberList.indices, id: \.self) { index in
                        if let image = UIImage(data: party.memberList[index].profileImageData) {
                            Image(uiImage: image)
                                .resizable()
                                .frame (width: 32, height: 32)
                                .clipShape(Circle())
                                .padding(.trailing, 24*CGFloat(index))
                        }
                    }
                    
                case 4...:
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
                    .padding(.trailing, 24*2)
                    
                default:
                    EmptyView()
                }
            }
            .disabled(party.memberList.isEmpty)
            .fullScreenCover(isPresented: $isMemberPopupPresented) {
                MemberPopupView(isMemberPopupPresented: $isMemberPopupPresented, memberList: party.memberList)
                    .foregroundStyle(.shotFF)
                    .presentationBackground(.black.opacity(0.7))
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
        }
        .padding(.top, 3)
        .padding(.bottom, 14)
        .padding(.horizontal, 16)
    }
}

struct ToastView: View {
    var message: String
    
    var body: some View {
        Text(message)
            .pretendard(.regular, 16)
            .foregroundStyle(.shotFF)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .padding(.top, 50)
    }
}

struct StepCell: View {
    var index: Int
    var step: Step
    var startDate: Date
    
    @State private var visibleMediaIndex = 0
    @State private var captureDates: [Date] = []
    @State private var isImageSaved = false
    @State private var showActionSheet = false
    @State private var showToast = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("STEP ")
                            .pretendard(.bold, 22)
                            .foregroundStyle(.shotC6)
                        
                        Text("0\(index+1)")
                            .pretendard(.bold, 22)
                            .foregroundStyle(.shotGreen)
                    }
                    
                    HStack(spacing: 0) {
                        Text(captureDates.isEmpty ? startDate.yearMonthDayNoSpace : captureDates[visibleMediaIndex].yearMonthDayNoSpace)
                            .pretendard(.semiBold, 14)
                            .foregroundStyle(.shotC6)
                            .opacity(0.4)
                        
                        Rectangle()
                            .foregroundStyle(.shot33)
                            .frame(width: 2, height: 10)
                            .cornerRadius(10)
                            .padding(.horizontal, 6)
                        
                        Text(captureDates.isEmpty ? startDate.aHourMinute : captureDates[visibleMediaIndex].aHourMinute)
                            .pretendard(.semiBold, 14)
                            .foregroundStyle(.shotC6)
                            .opacity(0.4)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                if !step.mediaList.isEmpty {
                    Button(action: {
                        showActionSheet = true
                    }, label: {
                        ZStack {
                            Image(.icnSave)
                                .resizable()
                                .frame(width: 35, height: 35)
                            
                            Image(symbol: .squareArrowDown)
                                .resizable()
                                .frame(width: 16, height: 20)
                                .pretendard(.semiBold, 16)
                                .foregroundStyle(.shotC6)
                                .offset(y: -1)
                        }
                    })
                    .actionSheet(isPresented: $showActionSheet) {
                        ActionSheet(
                            title: Text("사진을 저장할 방법을 선택해 주세요"),
                            buttons: [
                                .cancel(Text("취소")),
                                .default(Text("전체 사진 저장"), action: {
                                    saveAllImages()
                                }),
                                .default(Text("현재 사진 저장"), action: {
                                    saveCurrentImage()
                                })
                            ]
                        )
                    }
                }
            }
            .padding(16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(step.mediaList.sorted(by: { $0.captureDate < $1.captureDate }).enumerated()), id: \.offset) { index, media in
                        ZStack(alignment: .topTrailing) {
                            if let image = UIImage(data: media.fileData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
                                    .cornerRadius(15)
                            }
                            
                            Text("\(index+1) / \(step.mediaList.count)")
                                .pretendard(.regular, 14)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundStyle(.shotFF)
                                .background(.black.opacity(0.5))
                                .cornerRadius(50)
                                .padding(.top, 16)
                                .padding(.trailing, 16)
                                .onAppear {
                                    captureDates.append(media.captureDate)
                                }
                        }
                        .onAppear {
                            visibleMediaIndex = index
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .padding(.bottom, 16)
        }
        .overlay(
            VStack {
                if showToast {
                    ToastView(message: "저장이 완료되었습니다")
                        .transition(.opacity)
                }
            }
                .animation(.easeInOut, value: showToast)
        )
    }
    
    func saveAllImages() {
        for media in step.mediaList {
            if let uiImage = UIImage(data: media.fileData) {
                let imageSaver = ImageSaver()
                imageSaver.saveImage(uiImage) { result in
                    switch result {
                    case .success:
                        isImageSaved = true
                        showToastMessage()
                        print("🎞️ 전체 사진 저장 완료")
                        HapticManager.shared.notification(type: .success)
                    case .failure(let error):
                        print("❌ 전체 사진 저장 실패: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func saveCurrentImage() {
        guard let uiImage = UIImage(data: step.mediaList.sorted(by: { $0.captureDate < $1.captureDate })[visibleMediaIndex].fileData) else { return }
        
        let imageSaver = ImageSaver()
        imageSaver.saveImage(uiImage) { result in
            switch result {
            case .success:
                isImageSaved = true
                showToastMessage()
                HapticManager.shared.notification(type: .success)
                print("📷 현재 사진 저장 완료")
            case .failure(let error):
                print("❌ 현재 사진 저장 실패: \(error.localizedDescription)")
            }
        }
    }
    
    func showToastMessage() {
        showToast = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            showToast = false
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PartyListView(
        party: Party(
            title: "포항공대대애앵앵",
            startDate: .now,
            notiCycle: 60,
            memberList: []
        )
    )
    .modelContainer(MockModelContainer.mock)
    .environment(
        PartyUseCase(
            dataService: PersistentDataService(modelContext: MockModelContainer.mock.mainContext),
            notificationService: NotificationService()
        )
    )
}
#endif
