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
    
    @State private var photoSaveUseCase = PhotoSaveUseCase(photoSaveService: PhotoSaveService())
    
    let party: Party
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        Group {
            ScrollView {
                ForEach(Array(party.sortedStepList.enumerated()), id: \.element) {
                    index, step in
                    StepListCellView(
                        index: index + 1,
                        step: step,
                        startDate: party.startDate
                    )
                }
            }
            .fullScreenCover(isPresented: $state.isResultViewPresented) {
                PartyResultView(rootView: .list)
            }
        }
        .environment(photoSaveUseCase)
    }
}

// MARK: - StepListCellView

private struct StepListCellView: View {
    
    @Environment(PhotoSaveUseCase<PhotoSaveService>.self) private var photoSaveUseCase
    
    @State private var captureDates: [Date] = []
    @State private var visibleMediaIndex = 0
    
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
                if photoSaveUseCase.state.isPhotoSaved {
                    ToastView(message: "저장이 완료되었습니다")
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut, value: photoSaveUseCase.state.isPhotoSaved)
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
                
                Text("\(index.intformatter)")
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
    
    @Environment(PhotoSaveUseCase<PhotoSaveService>.self) private var photoSaveUseCase
    
    @State private var showActionSheet = false
    
    @Binding private(set) var visibleMediaIndex: Int
    
    let step: Step
    
    /// 현재 보고 있는 이미지를 반환합니다.
    private var currentPhoto: CapturePhoto {
        let sortedMediaList = step.mediaList.sorted { $0.captureDate < $1.captureDate }
        guard let uiImage = UIImage(data: sortedMediaList[visibleMediaIndex].fileData)
        else { return CapturePhoto(image: UIImage(resource: .appLogo)) }
        return CapturePhoto(image: uiImage)
    }
    
    /// 현재 STEP의 전체 이미지를 반환합니다.
    private var currentPhotos: [CapturePhoto] {
        var images: [UIImage] = []
        let sortedMediaList = step.mediaList.sorted { $0.captureDate < $1.captureDate }
        for media in sortedMediaList {
            guard let uiImage = UIImage(data: media.fileData)
            else { return [] }
            images.append(uiImage)
        }
        return images.map { CapturePhoto(image: $0) }
    }
    
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
                        photoSaveUseCase.saveAllPhotos(currentPhotos)
                    }),
                    .default(Text("현재 사진 저장"), action: {
                        photoSaveUseCase.saveCurrentPhoto(currentPhoto)
                    })
                ]
            )
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
                ForEach(Array(sortedMediaList.enumerated()), id: \.element) {
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
    .modelContainer(MockModelContainer.mock)
}
#endif
