//
//  PartyResultVIew.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyResultView: View {
    
    let rows = [
        GridItem(.flexible())
    ]
    
    let members : [String] = ["김민준","곽민준","오띵진","정혜정"]
    
    @State private var isShutDown: Bool = true
    
    
    var body: some View {
        VStack{
            if isShutDown{
                HStack{
                    Spacer()
                    Image(systemName: "questionmark.circle")
                }
                .padding(.trailing)
            }
            
            
            Circle()
                .stroke(Color.shotGreen, lineWidth: 2)
                .foregroundColor(.shotGreen)
                .frame(width: 120, height: 120)
                .overlay(
                Circle()
                    .foregroundColor(.shotGreen)
                    .padding(8)
                )
                .overlay(
                    VStack{
                        Image(systemName: "checkmark.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 36, height: 36)
                            .padding(.bottom, 4)
                            .foregroundColor(.shotFF)
                            
                            .background(
                                Circle()
                                .fill(.shot00)
                                .padding(4))
                            
                        Text("STEP 12")
                            .foregroundColor(.shot00)
                            .pretendard(.bold, 20)
                    }
                )
            // Circle()
            
            VStack{
                Text("포항공대 축제")
                    .foregroundColor(.shotFF)
                    .pretendard(.extraBold, 20)
                
                if isShutDown{
                    Text("시간이 지나 술자리를 종료했어요!")
                        .foregroundColor(.shot6D)
                        .pretendard(.bold, 14)
                }
                
            }
            .padding(.vertical, 8)
                
            List{
                Section{
                    VStack(alignment: .leading){
                        HStack{
                            Circle()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.shotGreen)
                            
                            Text("날짜")
                                .pretendard(.bold, 20)
                            
                        }
                        
                        Text("2024년 5월 13일 (월)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 24)
                        
                    }
                    
                    VStack(alignment: .leading){
                        HStack{
                            Circle()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.shotGreen)
                            
                            Text("진행 시간")
                                .pretendard(.bold, 20)
                            
                        }
                        
                        Text("18:30 ~ 2:00")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 24)
                        
                    }
                }
                
                Section{
                    VStack(alignment: .leading){
                        HStack{
                            Circle()
                                .frame(width: 16, height: 16)
                                .foregroundColor(.shotGreen)
                            
                            Text("함께한 사람들")
                                .pretendard(.bold, 20)
                            
                        }
                        
                        LazyHGrid(rows: rows){
                            ForEach(members, id: \.self){ member in
                                
                                Circle()
                                    .frame(width: 54, height: 54)
                                
                            }
                            
                        }
                        
                    }
                }
            }
            
            HStack(spacing: 8) {
                ActionButton(
                    title: "홈으로 돌아가기",
                    buttonType: .secondary
                ) {}
                
                ActionButton(
                    title: "그룹으로 이동",
                    buttonType: .primary
                ) {}
            }
            .padding()
            
        }
    }
}

#Preview {
    PartyResultView()
}
