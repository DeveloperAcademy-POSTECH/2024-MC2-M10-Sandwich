//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - PartyCameraView

struct PartyCameraView: View {
    
    @Environment(PartyCameraUseCase.self) private var cameraUseCase
    
    @StateObject private var cameraPathModel: CameraPathModel = .init()
    
    @Query private var partys: [Party]
    
    @Binding private(set) var isCameraViewPresented: Bool
    @Binding private(set) var isPartyResultViewPresented: Bool
    
    var body: some View {
        NavigationStack(path: $cameraPathModel.paths) {
            VStack{
                CameraHeaderView(
                    isCameraViewPresented: $isCameraViewPresented,
                    isPartyResultViewPresented: $isPartyResultViewPresented
                )
                
                CameraMiddleView()
                
                Spacer().frame(height: 48)
                
                CameraBottomView(isPartyResultViewPresented: $isPartyResultViewPresented)
            }
            .navigationDestination(for: CameraPathType.self) { path in
                switch path {
                case let .partyList(party):
                    PartyListView(party: party, isCameraViewPresented: $isCameraViewPresented)
                }
            }
            .fullScreenCover(isPresented: $isPartyResultViewPresented) {
                isCameraViewPresented = false
            } content: {
                PartyResultView(isPartyResultViewPresented: $isPartyResultViewPresented)
            }
        }
        .environmentObject(cameraPathModel)
        .onAppear {
            cameraUseCase.requestPermission()
        }
    }
}

// MARK: - CameraHeaderView

private struct CameraHeaderView: View {
    
    @Environment(PartyCameraUseCase.self) private var cameraUseCase
    
    @Query private var partys: [Party]
    
    @State private var isFinishPopupPresented = false
    
    @Binding private(set) var isCameraViewPresented: Bool
    @Binding private(set) var isPartyResultViewPresented: Bool
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    var body: some View {
        ZStack {
            if cameraUseCase.state.isCaptureMode {
                HStack {
                    Button{
                        isCameraViewPresented.toggle()
                    } label: {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.shotFF)
                            .padding(.leading,16)
                    }
                    // .disabled(viewModel.isShotDisabled)
                    
                    Spacer()
                    
                    Button {
                        HapticManager.shared.notification(type: .warning)
                        isFinishPopupPresented.toggle()
                    } label: {
                        Text("술자리 종료")
                            .pretendard(.semiBold, 16)
                            .foregroundColor(.shotGreen)
                    }
                    // .disabled(viewModel.isShotDisabled)
                }
                .padding(.horizontal)
                .padding(.top,12)
            }
            
            StepInfoView()
        }
        .fullScreenCover(isPresented: $isFinishPopupPresented) {
            FinishPopupView(
                isFinishPopupPresented: $isFinishPopupPresented,
                memberList: currentParty!.memberList
            )
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
    
    @Environment(PartyCameraUseCase.self) private var cameraUseCase
    
    @EnvironmentObject private var cameraPathModel: CameraPathModel
    
    @Query private var partys: [Party]
    
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
                Button{
                    if let lastParty = partys.last {
                        cameraPathModel.paths.append(.partyList(party: lastParty))
                    }
                } label: {
                    HStack{
                        Text(partys.last?.title ?? "제목입니당")
                            .pretendard(.bold, 20)
                            .foregroundColor(.shotFF)
                        Image(systemName: "chevron.right")
                            .foregroundColor(.shotFF)
                    }
                }
                // .disabled(viewModel.isShotDisabled)
            }
            
            else {
                Text(partys.last?.title ?? "제목입니당")
                    .pretendard(.bold, 20)
                    .foregroundColor(.shotFF)
            }
        }
    }
}

// MARK: - CameraBottomView

private struct CameraBottomView: View {
    
    @Environment(PartyCameraUseCase.self) private var cameraUseCase
    
    @Binding private(set) var isPartyResultViewPresented: Bool
    
    var body: some View {
        ZStack {
            HStack {
                // 촬영 전
                if cameraUseCase.state.isCaptureMode {
                    Button {
                        cameraUseCase.toggleFlashMode()
                    } label: {
                        if cameraUseCase.state.isFlashMode {
                            Image(systemName: "bolt")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.shotFF)
                        } else {
                            Image(systemName: "bolt.slash")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.shotFF)
                        }
                    }
                    // .disabled(viewModel.isShotDisabled)
                    
                    Spacer()
                    
                    Button {
                        cameraUseCase.toggleFrontBack()
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.shotFF)
                    }
                    //.disabled(viewModel.isShotDisabled)
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
                    //.disabled(viewModel.isShotDisabled)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 36)
            
            CaptureButtonView(isPartyResultViewPresented: $isPartyResultViewPresented)
            
            .padding(.top, 15)
        }
    }
}

// MARK: - CaptureButtonView

private struct CaptureButtonView: View {
    
    @Environment(PartyCameraUseCase.self) private var cameraUseCase
    
    @Query private var partys: [Party]

    @Binding var isPartyResultViewPresented: Bool
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    var body: some View {
        Button {
            cameraUseCase.state.isCaptureMode ?
            cameraUseCase.capturePhoto() : cameraUseCase.savePhoto()
        } label: {
            ZStack{
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
                    
                    Image(systemName: "arrow.up.forward")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                        .foregroundColor(.shot00)
                }
            }
            .padding(.bottom, 15)
        }
        // .disabled(isShotDisabled)
    }
    
    private func takePhoto() {
        
        HapticManager.shared.notification(type: .success)
        
        if let lastParty = currentParty,
           let lastStep = lastParty.sortedStepList.last {
            
            // 만약 현재 촬영하는 사진이 이번 STEP의 첫번째 사진이라면
            if lastStep.mediaList.isEmpty {
                
                // 기존 배너 알림 예약 취소 + 배너 알림 예약
                PartyService.shared.stepComplete()
                
                // 예약된 모든 함수 취소
                NotificationManager.instance.cancelFunction()
                
                // 다음 STEP 종료 결과 화면 예약
                NotificationManager.instance.scheduleFunction(date: PartyService.shared.nextStepEndDate) {
                    isPartyResultViewPresented.toggle()
                    lastParty.isShutdown = true
                }
                
                // 새로운 빈 STEP 생성 예약
                NotificationManager.instance.scheduleFunction(date: PartyService.shared.nextStepStartDate) {
                    
                    // 스텝 추가
                    let newStep = Step()
                    lastParty.stepList.append(newStep)
                }
            }
        }
    }
    
//    private func delayButton() {
//        print("버튼 눌림")
//        
//        // 버튼을 비활성화
//        isShotDisabled = true
//        
//        // 1초 후에 버튼을 다시 활성화
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            isShotDisabled = false
//        }
//    }
}

// MARK: - StepInfoView

private struct StepInfoView: View {
    
    @Query private var partys: [Party]
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let lastParty = currentParty,
               let lastStep = lastParty.sortedStepList.last {
                // 만약 현재 촬영하는 사진이 이번 STEP의 첫번째 사진이라면
                if lastStep.mediaList.isEmpty {
                    ZStack{
                        Image("icnSave")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25,height: 25)
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12,height: 12)
                            .foregroundColor(.shotD8)
                    }
                    .padding(.bottom, 2)
                } else {
                    ZStack{
                        Image("Greenbottle")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 25,height: 25)
                        
                        Image(systemName: "checkmark")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12,height: 12)
                            .foregroundColor(.shot00)
                    }
                    .padding(.bottom, 2)
                }
            }
            
            Text("STEP \(partys.last?.stepList.count.intformatter ?? "02")")
                .pretendard(.extraBold, 20)
                .foregroundColor(.shotFF)
            
            Text("\(partys.last?.notiCycle ?? 60)min")
                .pretendard(.bold, 15)
                .foregroundColor(.shot6D)
        }
    }
}

// MARK: - Preview

#if DEBUG
//#Preview {
//    PartyCameraView(
//        cameraUseCase: PartyCameraUseCase(cameraService: PartyCameraService()),
//        isCameraViewPresented: .constant(true),
//        isPartyResultViewPresented: .constant(false)
//    )
//}
#endif
