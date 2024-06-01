//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct PartyCameraView: View {
    
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject private var persistentDataManager: PersistentDataManager
    
    @StateObject private var cameraPathModel: CameraPathModel = .init()
    @StateObject var viewManager = CameraViewManager()
    
    @Query private var partys: [Party]
    
    @State private var isCamera = true
    @State private var isBolt = false
    @State private var isFace = false
    @State private var isShot = false
    @State private var isShotDisabled = false
    @State private var isPartyEnd = false
    @State private var isFinishPopupPresented = false
    
    @Binding var isCameraViewPresented: Bool
    @Binding var isPartyResultViewPresented: Bool
    
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    /// 현재 파티가 라이브인지 확인하는 계산 속성
    var isCurrentPartyLive: Bool {
        if let safeParty = currentParty {
            return safeParty.isLive
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationStack(path: $cameraPathModel.paths) {
            VStack{
                HeaderView
                MiddleView
                Spacer().frame(height: 48)
                BottomView
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
    }
    
    // MARK: - HeaderView
    var HeaderView: some View {
        ZStack{
            if !viewManager.isShot {
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
                    .disabled(isShotDisabled)
                    
                    Spacer()
                    
                    Button{
                        HapticManager.shared.notification(type: .warning)
                        isFinishPopupPresented.toggle()
                    } label: {
                        Text("술자리 종료")
                            .pretendard(.semiBold, 16)
                            .foregroundColor(.shotGreen)
                    }
                    .disabled(isShotDisabled)
                }
                .padding(.horizontal)
                .padding(.top,12)
            }
            
            StepInfoView()
        }
        .fullScreenCover(isPresented: $isFinishPopupPresented, onDismiss: {
            if isPartyEnd {
                isPartyResultViewPresented.toggle()
            }
        }, content: {
            FinishPopupView(
                isFinishPopupPresented: $isFinishPopupPresented,
                isPartyEnd: $isPartyEnd,
                memberList: currentParty!.memberList
            )
            .foregroundStyle(.shotFF)
            .presentationBackground(.black.opacity(0.7))
        })
        .transaction { transaction in
            transaction.disablesAnimations = true
        }
    }
    
    // MARK: - MiddleView
    var MiddleView: some View {
        Group {
            ZStack {
                viewManager.cameraPreview
                    .ignoresSafeArea()
                    .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(15)
                    .padding(.top, 36)
                
                
                if viewManager.isPhotoCaptureDone {
                    Image(uiImage: viewManager.recentImage ?? UIImage(resource: .appLogo))
                        .resizable()
                        .scaledToFill()
                        .frame(width: ScreenSize.screenWidth, height: ScreenSize.screenWidth)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(15)
                        .padding(.top, 36)
                }
            }
            
            // 촬영 전
            if !viewManager.isShot {
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
                .disabled(isShotDisabled)
            }
            
            // 촬영 후
            else {
                Text(partys.last?.title ?? "제목입니당")
                    .pretendard(.bold, 20)
                    .foregroundColor(.shotFF)
            }
        }
    }
    
    // MARK: - BottomView
    var BottomView: some View {
        ZStack {
            HStack {
                // MARK: - 플래시 + 셀카 전환
                // 촬영 전
                if !viewManager.isShot {
                    Button {
                        print("플래시")
                        if isFace || !isCamera{
                            isBolt = false
                        } else {
                            isBolt.toggle()
                        }
                    } label: {
                        if isBolt {
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
                    .disabled(isShotDisabled)
                    
                    Spacer()
                    
                    Button{
                        print("화면전환")
                        viewManager.changeCamera()
                        isFace.toggle()
                        if isFace {
                            isBolt = false
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 32, height: 32)
                            .foregroundColor(.shotFF)
                    }
                    .disabled(isShotDisabled)
                }
                
                // 촬영 후
                else {
                    Button {
                        if viewManager.isShot {
                            viewManager.retakePhoto()
                        }
                    } label: {
                        Text("다시찍기")
                            .foregroundColor(.shotFF)
                            .pretendard(.extraBold, 20)
                    }
                    .disabled(isShotDisabled)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 36)
            
            
            // MARK: - 카메라 버튼
            CaptureButtonView(
                viewManager: viewManager,
                isBolt: $isBolt,
                isShotDisabled: $isShotDisabled,
                isPartyResultViewPresented: $isPartyResultViewPresented
            )
            .padding(.top, 15)
        }
    }
}

#Preview {
    PartyCameraView(
        isCameraViewPresented: .constant(true),
        isPartyResultViewPresented: .constant(false)
    )
}

// MARK: - CaptureButtonView
private struct CaptureButtonView: View {
    
    @ObservedObject var viewManager: CameraViewManager
    
    @Query private var partys: [Party]
    
    @Binding var isBolt: Bool
    @Binding var isShotDisabled: Bool
    @Binding var isPartyResultViewPresented: Bool
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    var body: some View {
        Button {
            if viewManager.isShot {
                viewManager.retakePhoto()
                takePhoto()
            } else {
                if isBolt{
                    viewManager.toggleFlash()
                    viewManager.capturePhoto()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // 0.5초 후에 플래시가 꺼짐
                        viewManager.toggleFlash()
                    }
                } else {
                    viewManager.capturePhoto()
                }
            }
            
            delayButton()
            
        } label: {
            ZStack{
                if viewManager.isShot {
                    Circle()
                        .fill(Color.shotGreen)
                        .frame(width: 96, height: 96)
                    Image(systemName: "arrow.up.forward")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 36)
                        .foregroundColor(.shot00)
                    
                } else{
                    Circle()
                        .fill(Color.shotFF)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 96, height: 96)
                        .overlay(Circle().stroke(Color.shotGreen, lineWidth: 4))
                }
            }
            .padding(.bottom, 15)
        }
        .disabled(isShotDisabled)
    }
    
    private func takePhoto() {
        
        HapticManager.shared.notification(type: .success)
        
        if let lastParty = currentParty,
           let lastStep = lastParty.sortedStepList.last {
            
            // MARK: - 만약 현재 촬영하는 사진이 이번 STEP의 첫번째 사진이라면
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
            
            // 사진 데이터 저장!
            let sortedSteps = lastParty.stepList.sorted { $0.createDate < $1.createDate }
            let newMedia = Media(fileData: viewManager.cropImage()!, captureDate: .now)
            sortedSteps.last?.mediaList.append(newMedia)
        }
    }
    
    private func delayButton() {
        print("버튼 눌림")
        
        // 버튼을 비활성화
        isShotDisabled = true
        
        // 1초 후에 버튼을 다시 활성화
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            isShotDisabled = false
        }
    }
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
        VStack(spacing: 0){
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
                }else{
                    
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


