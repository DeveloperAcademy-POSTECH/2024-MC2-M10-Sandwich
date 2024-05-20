//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData
import AVFoundation

struct PartyCameraView: View {
    @Query private var partys: [Party]
    
    @State private var isCamera: Bool = true
    @State private var isBolt: Bool = false
    @State private var isFace: Bool = false
    @State private var isFinishPopupPresented: Bool = false
    @EnvironmentObject private var pathModel: PathModel
    @EnvironmentObject private var persistentDataManager: PersistentDataManager
    
    // camera
    @ObservedObject var viewManager = CameraViewManager()
    
    @State private var isShowingImageModal = false
    @State private var isShot = false
    
    var body: some View {
        VStack{
            ZStack{
                HStack{
                    if !isShot{
                        Button{
                            pathModel.paths.removeAll()
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
            .fullScreenCover(isPresented: $isFinishPopupPresented) {
                FinishPopupView(isFinishPopupPresented: $isFinishPopupPresented)
                    .foregroundStyle(.shotFF)
                    .presentationBackground(.black.opacity(0.7))
            }
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
                        pathModel.paths.append(.partyList(party: lastParty))
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
                        print("비디오")
                        isCamera = false
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
                        viewManager.capturePhoto()
                        
                        if isShot {
                            viewManager.retakePhoto()
//                            viewManager.saveImage()
                            
                            if let lastParty = partys.last{
                                persistentDataManager.saveImage(party: partys.last ?? lastParty , imageData: viewManager.cropImage()!)
                            }
                        }
                        
                        if isBolt{
                            viewManager.toggleFlash()
                        }
                        
                        isShot.toggle()
                        
                    } label: {
                        ZStack{
                            Circle()
                                .fill(isShot ? Color.shotGreen : Color.shotFF)
                                .frame(width: 112, height: 112)
                            
                            if isShot{
                                Image(systemName: "arrow.up.forward")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 36)
                                    .foregroundColor(.shot00)
                            } else{
                                Circle().stroke(Color.shotGreen, lineWidth: 10)
                                    .padding(12)
                            }
                        }
                    }
                }
                
                
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .navigationBarBackButtonHidden()
        .padding(16)
        
    }
}


struct CameraPreviewView: UIViewRepresentable {
    class VideoPreviewView: UIView {
        override class var layerClass: AnyClass {
            AVCaptureVideoPreviewLayer.self
        }
        
        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }
    
    let session: AVCaptureSession
    
    func makeUIView(context: Context) -> VideoPreviewView {
        let view = VideoPreviewView()
        
        view.videoPreviewLayer.session = session
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        view.videoPreviewLayer.cornerRadius = 0
        view.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        return view
    }
    
    func updateUIView(_ uiView: VideoPreviewView, context: Context) {
        
    }
}

#Preview {
    PartyCameraView()
}


// TODO: - 나중에 PartyListView에 적용
//struct testView: View {
//    @Query private var partys: [Party]
//    
//    @Binding var istestPresent: Bool
//    var body: some View {
//        VStack {
//            ForEach(partys.last?.stepList.last?.mediaList ?? [] ) { data in
//                if let image = UIImage(data: data.fileData) {
//                                Image(uiImage: image)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: 100, height: 100)
//                                    .cornerRadius(10)
//                            }
//                        }
//                    }
//    }
//}
