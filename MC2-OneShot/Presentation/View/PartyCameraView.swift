//
//  PartyCameraView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyCameraView: View {
    
    @State private var iscamera: Bool = true
    @State private var isbolt: Bool = false
    
    var body: some View {
        
        VStack{
            ZStack{
                HStack{
                    Button{
                        print("home")
                    } label: {
                        Image(systemName: "chevron.down")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .foregroundColor(.shotFF)
                    }
                    
                    Spacer()
                    
                    Button{
                        print("술자리 종료")
                    } label: {
                        Text("술자리 종료")
                            .pretendard(.extraBold, 15)
                            .foregroundColor(.shotGreen)
                    }
                }
                .padding(.horizontal, 8)
                
                VStack{
                    Image(systemName: "checkmark.circle.fill")
                        .padding(.bottom, 4)
                        .foregroundColor(.shotGreen)
                    Text("STEP 01")
                        .pretendard(.extraBold, 20)
                        .foregroundColor(.shotFF)
                    Text("120min")
                        .pretendard(.light, 15)
                        .foregroundColor(.shot6D)
                }
            }
            
            Rectangle()
                .frame(width: 360, height: 360)
                .cornerRadius(25)
                .padding(.top, 36)
            
            Button{
                print("리스트 가기")
            } label: {
                HStack{
                    Text("포항공대 축제")
                        .pretendard(.bold, 20)
                        .foregroundColor(.shotFF)
                    Image(systemName: "chevron.right")
                        .foregroundColor(.shotFF)
                }
            }
            
            HStack{
                Button{
                    print("사진")
                    iscamera = true
                } label: {
                    Text("사진")
                        .pretendard(.bold, 17)
                        .foregroundColor(iscamera ? .shotFF : .shot6D)
                        .frame(width: 64, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(iscamera ? Color.shot7B : Color.clear)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(iscamera ? Color.shotGreen : Color.shot6D, lineWidth: 0.33)))
                        
                }
                
                Button{
                    print("비디오")
                    iscamera = false
                } label: {
                    Text("비디오")
                        .pretendard(.bold, 17)
                        .foregroundColor(iscamera ? .shot6D : .shotFF)
                        .frame(width: 64, height: 40)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(iscamera ? Color.clear : Color.shot7B)
                                .overlay(RoundedRectangle(cornerRadius: 20)
                                    .stroke(iscamera ? Color.shot6D : Color.shotGreen, lineWidth: 0.33)))
                }
            }
            .padding(.top, 32)
            
            HStack{
                Button{
                    print("플래시")
                    isbolt.toggle()
                } label: {
                    if isbolt {
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
                
                Spacer()
                
                Button{
                    print("찰칵")
                } label: {
                    Circle()
                        .fill(Color.shotFF)
                        .overlay(
                            Circle().stroke(Color.shotGreen, lineWidth: 10)
                                .padding(12)
                        )
                }
                
                Spacer()
                
                Button{
                    print("화면전환")
                } label: {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)
                        .foregroundColor(.shotFF)
                }
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .padding(16)
        
    }
}

#Preview {
    PartyCameraView()
}
