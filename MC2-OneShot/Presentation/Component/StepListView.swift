//
//  StepListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/6/24.
//

import SwiftUI

// MARK: - StepListView

struct StepListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    
    let party: Party
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        ScrollView {
            ForEach(Array(party.stepList.enumerated()), id: \.element) {
                index, step in
                StepListCellView(
                    index: index,
                    step: step,
                    startDate: party.startDate
                )
            }
        }
        .fullScreenCover(isPresented: $state.isResultViewPresented) {
            PartyResultView(rootView: .list)
        }
    }
}

// MARK: - StepListCellView

private struct StepListCellView: View {
    
    @State private var captureDates: [Date] = []
    @State private var visibleMediaIndex = 0
    @State private var isImageSaveShowToastPresented = false
    
    let index: Int
    let step: Step
    let startDate: Date
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                StepListCellTitleView(
                    captureDates: $captureDates,
                    visibleMediaIndex: $visibleMediaIndex,
                    index: index,
                    startDate: startDate
                )
                
                Spacer()
                
                if !step.mediaList.isEmpty {
                    ImageSaveButton(
                        isImageSaveShowToastPresented: $isImageSaveShowToastPresented,
                        visibleMediaIndex: $visibleMediaIndex,
                        step: step
                    )
                }
            }
            .padding(16)
            
            StepListCellImageSlider(
                captureDates: $captureDates,
                visibleMediaIndex: $visibleMediaIndex,
                step: step
            )
        }
        .overlay(
            Group {
                if isImageSaveShowToastPresented {
                    ToastView(message: "저장이 완료되었습니다")
                        .transition(.opacity)
                }
            }
                .animation(.easeInOut, value: isImageSaveShowToastPresented)
        )
    }
}

// MARK: - StepListCellHeaderView

private struct StepListCellTitleView: View {
    
    @Binding private(set) var captureDates: [Date]
    @Binding private(set) var visibleMediaIndex: Int
    
    let index: Int
    let startDate: Date
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("STEP ")
                    .foregroundStyle(.shotC6)
                
                Text("0\(index + 1)")
                    .pretendard(.bold, 22)
                    .foregroundStyle(.shotGreen)
            }
            .pretendard(.bold, 22)
            
            HStack(spacing: 0) {
                Text(
                    captureDates.isEmpty
                    ? startDate.yearMonthDayNoSpace
                    : captureDates[visibleMediaIndex].yearMonthDayNoSpace
                )
                .pretendard(.semiBold, 14)
                .foregroundStyle(.shotC6)
                .opacity(0.4)
                
                Rectangle()
                    .foregroundStyle(.shot33)
                    .frame(width: 2, height: 10)
                    .cornerRadius(10)
                    .padding(.horizontal, 6)
                
                Text(
                    captureDates.isEmpty
                    ? startDate.aHourMinute
                    : captureDates[visibleMediaIndex].aHourMinute
                )
                .pretendard(.semiBold, 14)
                .foregroundStyle(.shotC6)
                .opacity(0.4)
            }
            .padding(.top, 4)
        }
    }
}

// MARK: - ImageSaveButton

private struct ImageSaveButton: View {
    
    @State private var showActionSheet = false
    @State private var isImageSaved = false
    
    @Binding private(set) var isImageSaveShowToastPresented: Bool
    @Binding private(set) var visibleMediaIndex: Int
    
    let step: Step
    
    var body: some View {
        Button {
            showActionSheet = true
        } label: {
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
        }
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
        guard let uiImage = UIImage(
            data: step.mediaList.sorted(by: {
                $0.captureDate < $1.captureDate
            })[visibleMediaIndex].fileData
        ) else { return }
        
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
        isImageSaveShowToastPresented = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isImageSaveShowToastPresented = false
        }
    }
}

// MARK: - StepListCellImageSlider

private struct StepListCellImageSlider: View {
    
    @Binding private(set) var captureDates: [Date]
    @Binding private(set) var visibleMediaIndex: Int
    
    let step: Step
    
    var sortedMediaList: [Media] {
        return step.mediaList.sorted { $0.captureDate < $1.captureDate }
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack {
                ForEach(Array(sortedMediaList.enumerated()), id: \.offset) {
                    index, media in
                    ZStack(alignment: .topTrailing) {
                        if let image = UIImage(data: media.fileData) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(
                                    width: ScreenSize.screenWidth,
                                    height: ScreenSize.screenWidth
                                )
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
                            .onAppear { captureDates.append(media.captureDate) }
                    }
                    .onAppear { visibleMediaIndex = index }
                }
            }
        }
        .scrollTargetLayout()
        .scrollTargetBehavior(.viewAligned)
        .padding(.bottom, 16)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    StepListView(
        party: Party(
            title: "테스트 파티",
            startDate: .now,
            notiCycle: 30,
            memberList: []
        )
    )
}
#endif
