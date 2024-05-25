//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct MemberCameraView: View {
    
    @StateObject var viewManager = CameraViewManager()
    
    @State private var isCamera = true
    @State private var isBolt = false
    @State private var isFace = false
    @State private var isShot = false
    @State private var isShotDisabled = false
    
    @Binding var isCameraViewPresented: Bool
    @Binding var membersInfo: [Member]
    
    var body: some View {
        VStack{
            HeaderView
            MiddleView
            Spacer().frame(height: 48)
            BottomView
        }
    }
    
    // MARK: - HeaderView
    var HeaderView: some View {
        ZStack {
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

                }
                .padding(.horizontal)
                .padding(.top, 4)
            }
            
            Text("참가자 프로필 촬영")
                .pretendard(.extraBold, 20)
                .foregroundColor(.shotFF)
               
        }
        .padding(.top, 27)
        .padding(.bottom, 16)
    }
    
    // MARK: - MiddleView
    var MiddleView: some View {
        ZStack {
            viewManager.cameraPreview
                .ignoresSafeArea()
                .frame(width: 393, height: 393)
                .aspectRatio(1, contentMode: .fit)
                .cornerRadius(15)
                .padding(.top, 36)
            
            if viewManager.isPhotoCaptureDone {
                Image(uiImage: viewManager.recentImage ?? UIImage(resource: .appLogo))
                    .resizable()
                    .scaledToFill()
                    .frame(width: 393, height: 393)
                    .aspectRatio(1, contentMode: .fit)
                    .cornerRadius(15)
                    .padding(.top, 36)
            }
        }
        .padding(.bottom, 10)
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
                membersInfo: $membersInfo,
                isCameraViewPresented: $isCameraViewPresented
            )
        }
        .padding(.top, 20)
    }
}


// MARK: - CaptureButtonView
private struct CaptureButtonView: View {
    
    @ObservedObject var viewManager: CameraViewManager

    @Binding var isBolt: Bool
    @Binding var isShotDisabled: Bool
    @Binding var membersInfo: [Member]
    @Binding var isCameraViewPresented: Bool
    
    var body: some View {
        Button {
            if viewManager.isShot {
                viewManager.retakePhoto()
                takePhoto()
            } else {
                if isBolt{
                    viewManager.toggleFlash()
                }
                viewManager.capturePhoto()
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
        
//        HapticManager.shared.notification(type: .success)
        
        let newMember = Member(profileImageData: viewManager.cropImage()!)
        membersInfo.append(newMember)
        
        isCameraViewPresented.toggle()
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
