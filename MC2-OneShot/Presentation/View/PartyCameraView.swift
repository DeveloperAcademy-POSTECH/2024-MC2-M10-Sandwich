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
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        NavigationStack(path: $cameraPathModel.paths) {
            VStack {
                CameraHeaderView()
                CameraMiddleView()
                Spacer().frame(height: 48)
                CameraBottomView(isShotDisabled: $isShotDisabled)
            }
            .navigationDestination(for: CameraPathType.self) { path in
                switch path {
                case let .partyList(party):
                    PartyListView(party: party)
                        .toolbarRole(.editor)
                }
            }
        }
        .disabled(isShotDisabled)
        .fullScreenCover(isPresented: $state.isResultViewPresented) {
            PartyResultView(rootView: .camera)
        }
        .environment(cameraUseCase)
        .environment(cameraPathModel)
        .onAppear { cameraUseCase.requestPermission() }
    }
}

// MARK: - CameraHeaderView

private struct CameraHeaderView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @State private var isFinishPopupPresented = false
    
    var body: some View {
        ZStack {
            if cameraUseCase.state.isCaptureMode {
                HStack {
                    Button{
                        partyUseCase.presentCameraView(to: false)
                    } label: {
                        Image(symbol: .chevronDown)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.shotFF)
                            .padding(.leading,16)
                    }
                    
                    Spacer()
                    
                    Button {
                        HapticManager.shared.notification(type: .warning)
                        isFinishPopupPresented.toggle()
                    } label: {
                        Text("술자리 종료")
                            .pretendard(.semiBold, 16)
                            .foregroundColor(.shotGreen)
                    }
                }
                .padding(.horizontal)
                .padding(.top,12)
            }
            
            StepInfoView()
        }
        .fullScreenCover(isPresented: $isFinishPopupPresented) {
            FinishPopupView(memberList: partyUseCase.partys.last?.memberList ?? [])
                .foregroundStyle(.shotFF)
                .presentationBackground(.black.opacity(0.7))
        }
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
}

// MARK: - CameraMiddleView

private struct CameraMiddleView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    @Environment(CameraPathModel.self) private var cameraPathModel
    
    var body: some View {
        Group {
            ZStack {
                cameraUseCase.preview
                    .ignoresSafeArea()
                    .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(15)
                    .padding(.top, 36)
                
                if cameraUseCase.state.isPhotoDataPrepare {
                    Image(uiImage: cameraUseCase.state.photoData?.image ?? UIImage(resource: .appLogo))
                        .resizable()
                        .scaledToFill()
                        .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(15)
                        .padding(.top, 36)
                }
            }
            
            if cameraUseCase.state.isCaptureMode {
                Button {
                    if let lastParty = partyUseCase.partys.last {
                        cameraPathModel.paths.append(.partyList(party: lastParty))
                    }
                } label: {
                    HStack {
                        Text(partyUseCase.partys.last?.title ?? "제목입니당")
                            .pretendard(.bold, 20)
                            .foregroundColor(.shotFF)
                        
                        Image(symbol: .chevronRight)
                            .foregroundColor(.shotFF)
                    }
                }
            }
            
            else {
                Text(partyUseCase.partys.last?.title ?? "제목입니당")
                    .pretendard(.bold, 20)
                    .foregroundColor(.shotFF)
            }
        }
    }
}

// MARK: - CameraBottomView

private struct CameraBottomView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(CameraUseCase.self) private var cameraUseCase
    
    @Binding private(set) var isShotDisabled: Bool
    
    var body: some View {
        ZStack {
            HStack {
                // 촬영 전
                if cameraUseCase.state.isCaptureMode {
                    Button {
                        cameraUseCase.toggleFlashMode()
                    } label: {
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
                    
                    Spacer()
                    
                    Button {
                        cameraUseCase.toggleFrontBack()
                    } label: {
                        Image(symbol: .frontBackToggle)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.shotFF)
                    }
                }
                
                // 촬영 후
                else {
                    Button {
                        cameraUseCase.retakePhoto()
                    } label: {
                        Text("다시찍기")
                            .foregroundColor(.shotFF)
                            .pretendard(.extraBold, 20)
                    }
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 36)
            
            CaptureButtonView(isShotDisabled: $isShotDisabled)
                .padding(.top, 15)
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
            
            // 카메라 촬영 모드
            if cameraUseCase.state.isCaptureMode {
                cameraUseCase.capturePhoto()
            }
            
            // 사진 전송 모드
            else {
                if let photo = cameraUseCase.fetchPhotoForSave() {
                    partyUseCase.savePhoto(photo)
                    cameraUseCase.retakePhoto()
                }
            }
        } label: {
            ZStack {
                if cameraUseCase.state.isCaptureMode {
                    Circle()
                        .fill(Color.shotFF)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(Color.shotGreen, lineWidth: 4))
                } else {
                    Circle()
                        .fill(Color.shotGreen)
                        .frame(width: 96, height: 96)
                    
                    Image(symbol: .arrowUpForward)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                        .foregroundColor(.shot00)
                }
            }
            .padding(.bottom, 15)
        }
    }
    
    /// 사진 촬영 직후 버튼을 잠시 비활성화 합니다.
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
            
            Text("STEP \(partyUseCase.partys.last?.stepList.count.intformatter ?? "01")")
                .pretendard(.extraBold, 20)
                .foregroundColor(.shotFF)
            
            Text("\(partyUseCase.partys.last?.notiCycle ?? 30)min")
                .pretendard(.bold, 15)
                .foregroundColor(.shot6D)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    PartyCameraView()
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
