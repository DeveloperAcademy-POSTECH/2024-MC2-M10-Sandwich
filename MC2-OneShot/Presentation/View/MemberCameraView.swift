//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - MemberCameraView

struct MemberCameraView: View {
    
    @State private var cameraUseCase = CameraUseCase(cameraService: CameraService())
    @State private var isShotDisabled = false
    @State private var isFlashDisabled = false
    
    var body: some View {
        VStack {
            CameraHeaderView()
            CameraMiddleView()
            Spacer().frame(height: 48)
            CameraBottomView(isFlashDisabled: $isFlashDisabled, isShotDisabled: $isShotDisabled)
        }
        .disabled(isShotDisabled)
        .environment(cameraUseCase)
        .onAppear {
            cameraUseCase.requestPermission()
            isFlashDisabled = cameraUseCase.state.isSelfieMode
        }
    }
}

// MARK: - CameraHeaderView

private struct CameraHeaderView: View {
    
    @Environment(CameraUseCase.self) private var cameraUseCase
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if cameraUseCase.state.isCaptureMode {
                HStack {
                    DismissButton()
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 12)
            }
            
            Text("참가자 프로필 촬영")
                .pretendard(.extraBold, 20)
                .foregroundColor(.shotFF)
        }
    }
    
    /// 홈 화면으로 돌아가는 버튼
    @ViewBuilder
    private func DismissButton() -> some View {
        Button{
            dismiss()
        } label: {
            Image(symbol: .chevronDown)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.shotFF)
                .padding(.leading,16)
        }
    }
}

// MARK: - CameraMiddleView

private struct CameraMiddleView: View {
    
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    var body: some View {
        VStack {
            ZStack {
                CameraPreview()
                if cameraUseCase.state.isPhotoDataPrepare {
                    PhotoPreview()
                }
            }
            if !cameraUseCase.state.isSelfieMode {
                HStack{
                    WideAngleButton()
                    GeneralAngleButton()
                }
            }
        }
    }
    
    /// 카메라 미리보기 뷰
    @ViewBuilder
    private func CameraPreview() -> some View {
        cameraUseCase.preview
            .ignoresSafeArea()
            .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(15)
            .padding(.top, 36)
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
            .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
            .aspectRatio(1, contentMode: .fit)
            .cornerRadius(15)
            .padding(.top, 36)
    }
    
    /// 광각 버튼
    @ViewBuilder
    private func WideAngleButton() -> some View {
        Button {
            cameraUseCase.wideAngle()
        } label: {
            ZStack{
                Circle()
                    .frame(width: 26, height: 26)
                    .foregroundColor(.shotFF)
                
                Text(".5")
                    .foregroundColor(.black)
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
                    .frame(width: 26, height: 26)
                    .foregroundColor(.shotFF)
                
                Text("1")
                    .foregroundColor(.black)
            }
        }
    }
}

// MARK: - CameraBottomView

private struct CameraBottomView: View {
    
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @Binding private(set) var isFlashDisabled: Bool
    @Binding private(set) var isShotDisabled: Bool
    
    var body: some View {
        ZStack {
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
            capturePhoto() : saveMemberPhoto()
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
    
    /// 멤버 사진을 저장합니다.
    private func saveMemberPhoto() {
        if let photo = cameraUseCase.fetchPhotoForSave() {
            partyUseCase.saveMemberPhoto(photo)
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

// MARK: - Preview

#if DEBUG
#Preview {
    MemberCameraView()
        .environment(
            PartyUseCase(
                dataService: PersistentDataService(
                    modelContext: ModelContainerCoordinator.mock.mainContext
                ),
                notificationService: NotificationService()
            )
        )
        .environment(CameraUseCase(cameraService: CameraService()))
}
#endif
