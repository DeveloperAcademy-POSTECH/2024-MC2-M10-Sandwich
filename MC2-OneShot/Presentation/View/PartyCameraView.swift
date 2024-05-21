//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct PartyCameraView: View {
    
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
    
    @State private var isShowingImageModal = false
    @State private var isFinishPopupPresented = false
    @State private var isPartyResultViewPresented = false
    
    @State private var croppedImage: UIImage? = nil
    
    @Binding var isCameraViewPresented: Bool
    
    var body: some View {
        NavigationStack(path: $cameraPathModel.paths) {
            VStack{
                ZStack{
                    HStack{
                        if !isShot{
                            Button{
                                isCameraViewPresented.toggle()
                            } label: {
                                Image(systemName: "chevron.down")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(.shotFF)
                            }
                        }
                        
                        Spacer()
                        
                        if !isShot{
                            Button{
                                isFinishPopupPresented.toggle()
                            } label: {
                                Text("술자리 종료")
                                    .pretendard(.extraBold, 15)
                                    .foregroundColor(.shotGreen)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    
                    VStack{
                        
                        // TODO: - check 활성 비활성화 만들기
                        Image(systemName: "checkmark.circle.fill")
                            .padding(.bottom, 4)
                            .foregroundColor(.shotGreen)
                        //                    Text("STEP \(intformatter(dummyPartys[0].stepList.count))")
                        Text("STEP \(partys.last?.stepList.count ?? 2)")
                            .pretendard(.extraBold, 20)
                            .foregroundColor(.shotFF)
                        //                    Text("\(dummyPartys[0].notiCycle)min")
                        Text("\(partys.last?.notiCycle ?? 60)min")
                            .pretendard(.light, 15)
                            .foregroundColor(.shot6D)
                    }
                }
                .fullScreenCover(isPresented: $isFinishPopupPresented, onDismiss: {
                    if isPartyEnd {
                        isPartyResultViewPresented.toggle()
                    }
                }, content: {
                    FinishPopupView(
                        isFinishPopupPresented: $isFinishPopupPresented,
                        isPartyEnd: $isPartyEnd
                    )
                    .foregroundStyle(.shotFF)
                    .presentationBackground(.black.opacity(0.7))
                })
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                
                VStack {
                    viewManager.cameraPreview.ignoresSafeArea()
                        .onAppear {
                            viewManager.configure()
                        }
                        .frame(width: 360, height: 360)
                        .aspectRatio(1, contentMode: .fit)
                        .cornerRadius(25)
                }
                .padding(.top, 36)
                
                if isShot{
                    //                Text("\(dummyPartys[0].title)")
                    Text(partys.last?.title ?? "제목입니당")
                        .pretendard(.bold, 20)
                        .foregroundColor(.shotFF)
                } else {
                    Button{
                        if let lastParty = partys.last {
                            cameraPathModel.paths.append(.partyList(party: lastParty))
                        }
                    } label: {
                        HStack{
                            //                        Text("\(dummyPartys[0].title)")
                            Text(partys.last?.title ?? "제목입니당")
                                .pretendard(.bold, 20)
                                .foregroundColor(.shotFF)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.shotFF)
                        }
                    }
                }
                
                HStack{
                    if !isShot{
                        Button{
                            print("사진")
                            isCamera = true
                        } label: {
                            Text("사진")
                                .pretendard(.bold, 17)
                                .foregroundColor(isCamera ? .shotFF : .shot6D)
                                .frame(width: 64, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isCamera ? Color.shot7B : Color.clear)
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(isCamera ? Color.shotGreen : Color.shot6D, lineWidth: 0.33)))
                            
                        }
                        
                        Button{
                            print("플래시")
                            if !isFace{
                                //                                viewManager.toggleFlash()
                                isBolt.toggle()
                            }
                        } label: {
                            Text("비디오")
                                .pretendard(.bold, 17)
                                .foregroundColor(isCamera ? .shot6D : .shotFF)
                                .frame(width: 64, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(isCamera ? Color.clear : Color.shot7B)
                                        .overlay(RoundedRectangle(cornerRadius: 20)
                                            .stroke(isCamera ? Color.shot6D : Color.shotGreen, lineWidth: 0.33)))
                        }
                    }
                }
                .padding(.top, isShot ? 76 : 32) // TODO: - 패딩 조정 필요
                
                ZStack{
                    HStack{
                        if isShot {
                            Button{
                                if isShot{
                                    viewManager.retakePhoto()
                                }
                                isShot.toggle()
                            } label: {
                                Text("다시찍기")
                                    .foregroundColor(.shotFF)
                                    .pretendard(.extraBold, 20)
                            }
                        } else{
                            Button{
                                print("플래시")
                                if !isFace{
                                    //                                viewManager.toggleFlash()
                                    isBolt.toggle()
                                }
                            } label: {
                                if isBolt {
                                    Image(systemName: "bolt")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.shotFF)
                                } else {
                                    Image(systemName: "bolt.slash")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 48, height: 48)
                                        .foregroundColor(.shotFF)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        if !isShot{
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
                                    .frame(width: 48, height: 48)
                                    .foregroundColor(.shotFF)
                            }
                        }
                    }
                    
                    VStack{
                        Button{
                            if isBolt && !isShot{
                                viewManager.toggleFlash()
                            }
                            
                            if isShot {
                                viewManager.retakePhoto()
                                
                                // 만약 현재 촬영하는 사진이 이번 STEP의 첫번째 사진이라면
                                if ((partys.last?.stepList.last?.mediaList.isEmpty) != nil) {
                                    PartyService.shared.stepComplete()
                                }
                                
                                if let lastParty = partys.last{
                                    persistentDataManager.saveMedia(party: lastParty , imageData: viewManager.cropImage()!)
                                }
                            } else {
                                
                                if isBolt{
                                    viewManager.toggleFlash()
                                }
                                
                                viewManager.capturePhoto()
                            }
                            
                            isShot.toggle()
                            delayButton()
                            
                        } label: {
                            ZStack{
                                if isShot{
                                    Circle()
                                        .fill(Color.shotGreen)
                                        .frame(width: 112, height: 112)
                                    Image(systemName: "arrow.up.forward")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: 36)
                                        .foregroundColor(.shot00)
                                } else{
                                    Circle()
                                        .fill(Color.shotFF)
                                        .frame(width: 112, height: 112)
                                    
                                    Circle().stroke(Color.shotGreen, lineWidth: 10)
                                        .padding(12)
                                }
                            }
                        }
                        .disabled(isShotDisabled)
                    }
                    .padding(.top)
                    .padding(.horizontal)
                }
                .padding(16)
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
    }
    
    private func delayButton() {
        print("버튼 눌림")
        
        // 버튼을 비활성화
        isShotDisabled = true
        
        // 0.5초 후에 버튼을 다시 활성화
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShotDisabled = false
        }
    }
}

#Preview {
    PartyCameraView(isCameraViewPresented: .constant(true))
}
