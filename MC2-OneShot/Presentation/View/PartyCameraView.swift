//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - PartyCameraView

struct PartyCameraView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    
    @State private var cameraUseCase = CameraUseCase(cameraService: CameraService())
    @State private var cameraPathModel: CameraPathModel = .init()
    @State private var isShotDisabled = false
    @State private var isFlashDisabled = false
    
    @Binding private(set) var isCameraViewPresented: Bool
    
    var body: some View {
        NavigationStack(path: $cameraPathModel.paths) {
            VStack {
                Spacer().frame(height: 16)
                CameraHeaderView(isCameraViewPresented: $isCameraViewPresented)
                Spacer().frame(height: 46)
                CameraMiddleView()
                Spacer().frame(height: 48)

                CameraBottomView(isFlashDisabled: $isFlashDisabled, isShotDisabled: $isShotDisabled)
                
                Spacer()
            }
            .cameraPathDestination()
        }
        .fullScreenCover(
            isPresented: .init(
                get: { partyUseCase.state.isResultViewPresented },
                set: { _ in })
        ) {
            PartyResultView(isCameraViewPresented: $isCameraViewPresented)
        }
        .disabled(isShotDisabled)
        .environment(cameraUseCase)
        .environment(cameraPathModel)
        .onAppear { cameraUseCase.requestPermission() }
        .onChange(of: isCameraViewPresented) { _, value in
            if !value {
                cameraUseCase.cancelSubscriptions()
            }
        }
    }
}

// MARK: - CameraHeaderView

private struct CameraHeaderView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @State private var isFinishPopupPresented = false
    
    @Binding private(set) var isCameraViewPresented: Bool
    
    var body: some View {
        ZStack {
            HStack {
                if cameraUseCase.state.isCaptureMode {
                    DismissButton()
                }
                Spacer()
                
                if !partyUseCase.state.isPartyShutdown {
                    FinishPartyButton()
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            
            StepInfoView()
        }
        .padding(.top, 12)
        .fullScreenCover(isPresented: $isFinishPopupPresented) {
            FinishPopupView(memberList: partyUseCase.partys.last?.memberList ?? [])
                .foregroundStyle(.shotFF)
                .presentationBackground(.black.opacity(0.7))
        }
        .transaction { $0.disablesAnimations = true }
    }
    
    /// 홈 화면으로 돌아가는 버튼
    @ViewBuilder
    private func DismissButton() -> some View {
        Button{
            isCameraViewPresented = false
        } label: {
            Image(symbol: .chevronDown)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.shotFF)
                .padding(.leading, 16)
        }
    }
    
    /// 술자리 종료 버튼
    @ViewBuilder
    private func FinishPartyButton() -> some View {
        Button {
            HapticManager.shared.notification(type: .warning)
            isFinishPopupPresented.toggle()
        } label: {
            Text("술자리 종료")
                .pretendard(.semiBold, 16)
                .foregroundColor(.shotGreen)
        }
    }
}

// MARK: - CameraMiddleView

private struct CameraMiddleView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    @Environment(CameraPathModel.self) private var cameraPathModel
    
    var body: some View {
        VStack {
            ZStack(alignment: .bottom) {
                CameraPreview()
                
                if !cameraUseCase.state.isSelfieMode
                    && cameraUseCase.state.isCaptureMode
                    && !partyUseCase.state.isPartyShutdown {
                    HStack(spacing: 6) {
                        WideAngleButton()
                        GeneralAngleButton()
                    }
                    .padding(.bottom, 12)
                }
            }
            
            ListButton()
        }
        .zIndex(-1)
    }
    
    /// 카메라 미리보기 뷰
    @ViewBuilder
    private func CameraPreview() -> some View {
        cameraUseCase.preview
            .overlay(alignment: .center) {
                if cameraUseCase.state.isPhotoDataPrepare {
                    PhotoPreview()
                }
            }
            .overlay(alignment: .center) {
                if partyUseCase.state.isPartyShutdown {
                    ZStack {
                        Rectangle()
                            .background(.ultraThinMaterial)
                        
                        Text("😵‍💫 미션 시간이 지나\n술자리가 종료되었어요!")
                            .pretendard(.bold, 20)
                            .foregroundStyle(.shotFF)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                    }
                }
            }
            .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(15)
            .clipped()
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        cameraUseCase.zoom(factor: value.magnification)
                    }
                    .onEnded { _ in
                        cameraUseCase.zoomInitialize()
                    }
            )
    }
    
    /// 사진 미리보기 뷰
    @ViewBuilder
    private func PhotoPreview() -> some View {
        Image(uiImage: cameraUseCase.state.photoData?.image ?? UIImage(resource: .appLogo))
            .resizable()
            .scaledToFill()
    }
    
    /// 리스트 바로가기 버튼
    @ViewBuilder
    private func ListButton() -> some View {
        Button {
            guard let currentParty = partyUseCase.partys.last else { return }
            cameraPathModel.paths.append(.partyList(party: currentParty))
        } label: {
            HStack {
                Text(partyUseCase.partys.last?.title ?? "제목입니당")
                    .pretendard(.bold, 20)
                
                if cameraUseCase.state.isCaptureMode { Image(symbol: .chevronRight) }
            }
            .foregroundColor(.shotFF)
        }
        .disabled(!cameraUseCase.state.isCaptureMode)
    }
    
    /// 광각 버튼
    @ViewBuilder
    private func WideAngleButton() -> some View {
        Button {
            cameraUseCase.wideAngle()
        } label: {
            ZStack{
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.shot00)
                    .opacity(0.3)
                
                Text(".5")
                    .pretendard(.medium, 13)
                    .foregroundColor(.shotFF)
            }
        }
    }
    
    /// 일반 각 버튼
    @ViewBuilder
    private func GeneralAngleButton() -> some View {
        Button {
            cameraUseCase.generalAngle()
        } label: {
            ZStack{
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(.shot00)
                    .opacity(0.3)
                
                Text("1x")
                    .pretendard(.medium, 13)
                    .foregroundColor(.shotFF)
            }
        }
    }
}

// MARK: - CameraBottomView

private struct CameraBottomView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @Binding private(set) var isFlashDisabled: Bool
    @Binding private(set) var isShotDisabled: Bool
    
    var body: some View {
        ZStack {
            if !partyUseCase.state.isPartyShutdown {
                HStack {
                    if cameraUseCase.state.isCaptureMode {
                        FlashButton()
                        Spacer()
                        FrontBackButton()
                    } else {
                        RetakeButton()
                    }
                }
                .padding(.horizontal, 36)
                
                CaptureButtonView(isShotDisabled: $isShotDisabled)
            } else {
                VStack {
                    Spacer()
                    
                    ActionButton(
                        title: "술자리 정리하기",
                        buttonType: .primary,
                        tapAction: {
                            HapticManager.shared.notification(type: .success)
                            partyUseCase.finishParty()
                        }
                    )
                    .padding(.horizontal, 16)
                }
            }
        }
    }
    
    /// 플래시 버튼
    @ViewBuilder
    private func FlashButton() -> some View {
        Button {
            if !cameraUseCase.state.isSelfieMode{
                cameraUseCase.toggleFlashMode()
            }
        } label: {
            if cameraUseCase.state.isSelfieMode {
                Image(symbol: .boltSlash)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundColor(.shotFF.opacity(0.5))
            } else {
                if cameraUseCase.state.isFlashMode {
                    Image(symbol: .bolt)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.shotFF)
                } else {
                    Image(symbol: .boltSlash)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.shotFF)
                }
            }
        }
        .rotationEffect(cameraUseCase.state.rotation)
        .animation(.easeInOut, value: cameraUseCase.state.orientation)
        .disabled(isFlashDisabled)
    }
    
    /// 전면/후면 카메라 전환 버튼
    @ViewBuilder
    private func FrontBackButton() -> some View {
        Button {
            delayButton()
            cameraUseCase.toggleFrontBack()
            isFlashDisabled = cameraUseCase.state.isSelfieMode
        } label: {
            Image(symbol: .frontBackToggle)
                .resizable()
                .scaledToFit()
                .frame(width: 32, height: 32)
                .foregroundColor(.shotFF)
        }
        .rotationEffect(cameraUseCase.state.rotation)
        .animation(.easeInOut, value: cameraUseCase.state.orientation)
    }
    
    /// 사진 촬영 이후 재촬영 버튼
    @ViewBuilder
    private func RetakeButton() -> some View {
        Button {
            cameraUseCase.retakePhoto()
        } label: {
            Text("다시찍기")
                .foregroundColor(.shotFF)
                .pretendard(.extraBold, 20)
        }
        
        Spacer()
    }
    
    /// 버튼을 누른 뒤 버튼을 잠시 비활성화 합니다.
    private func delayButton() {
        isShotDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShotDisabled = false
        }
    }
}

// MARK: - CaptureButtonView

private struct CaptureButtonView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @Binding private(set) var isShotDisabled: Bool
    
    var body: some View {
        Button {
            delayButton()
            cameraUseCase.state.isCaptureMode ?
            capturePhoto() : uploadPhoto()
        } label: {
            ZStack {
                if cameraUseCase.state.isCaptureMode {
                    CaptureButton()
                } else {
                    UploadButton()
                }
            }
            .padding(.bottom, 15)
        }
        .padding(.top, 15)
    }
    
    /// 카메라 촬영 버튼
    @ViewBuilder
    private func CaptureButton() -> some View {
        Circle()
            .fill(Color.shotFF)
            .frame(width: 80, height: 80)
        
        Circle()
            .fill(Color.clear)
            .frame(width: 96, height: 96)
            .overlay(Circle().stroke(Color.shotGreen, lineWidth: 4))
    }
    
    /// 사진 업로드 버튼
    @ViewBuilder
    private func UploadButton() -> some View {
        Circle()
            .fill(Color.shotGreen)
            .frame(width: 96, height: 96)
        
        Image(symbol: .arrowUpForward)
            .resizable()
            .scaledToFit()
            .frame(height: 36)
            .foregroundColor(.shot00)
    }
    
    /// 사진을 촬영합니다.
    private func capturePhoto() {
        cameraUseCase.capturePhoto()
    }
    
    /// 사진을 업로드합니다.
    private func uploadPhoto() {
        if let photo = cameraUseCase.fetchPhotoForSave() {
            partyUseCase.saveStepPhoto(photo)
            cameraUseCase.retakePhoto()
        }
    }
    
    /// 버튼을 누른 뒤 버튼을 잠시 비활성화 합니다.
    private func delayButton() {
        isShotDisabled = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShotDisabled = false
        }
    }
}

// MARK: - StepInfoView

private struct StepInfoView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    
    var body: some View {
        VStack(spacing: 0) {
            if let currentParty = partyUseCase.partys.last,
               let lastStep = currentParty.sortedStepList.last {
                ZStack {
                    Image(lastStep.mediaList.isEmpty ? .icnSave : .greenbottle)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 25, height: 25)
                    
                    Image(symbol: .checkmark)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12,height: 12)
                        .foregroundColor(lastStep.mediaList.isEmpty ? .shotD8 : .shot00)
                }
                .padding(.bottom, 2)
            }
            
            Text(stepLabel)
                .pretendard(.extraBold, 20)
                .foregroundColor(.shotFF)
            
            Text(notiCycleLabel)
                .pretendard(.bold, 15)
                .foregroundColor(.shot6D)
        }
    }
    
    /// Step에 표시할 텍스트 정보를 반환합니다.
    private var stepLabel: String {
        return "STEP \(partyUseCase.partys.last?.stepList.count.intformatter ?? "01")"
    }
    
    /// NotiCycle에 표시할 텍스트 정보를 반환합니다.
    private var notiCycleLabel: String {
        return "\(partyUseCase.partys.last?.notiCycle ?? 30)min"
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PartyCameraView(isCameraViewPresented: .constant(true))
        .environment(
            PartyUseCase(
                dataService: PersistentDataService(
                    modelContext: ModelContainerCoordinator.mock.mainContext
                ),
                notificationService: NotificationService()
            )
        )
}
#endif
