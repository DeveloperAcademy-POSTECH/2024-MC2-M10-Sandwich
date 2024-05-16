//
//  PartyResultVIew.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyResultView: View {
    
    @EnvironmentObject private var pathModel: PathModel
    
    var body: some View {
        VStack{
            if dummyPartys[0].isShutdown{
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
                            
                        Text("STEP \(dummyPartys[0].stepList.count)")
                            .foregroundColor(.shot00)
                            .pretendard(.bold, 20)
                    }
                )
            
            VStack{
                Text("\(dummyPartys[0].title)")
                    .foregroundColor(.shotFF)
                    .pretendard(.extraBold, 20)
                
                if dummyPartys[0].isShutdown{
                    Text("시간이 지나 술자리를 종료했어요!")
                        .foregroundColor(.shot6D)
                        .pretendard(.bold, 14)
                }
            }
            .padding(.vertical, 8)
                
            ListView()
            
            HStack(spacing: 8) {
                ActionButton(
                    title: "홈으로 돌아가기",
                    buttonType: .secondary
                ) {
                    pathModel.paths.removeAll()
                }
                
                ActionButton(
                    title: "그룹으로 이동",
                    buttonType: .primary
                ) {
                    pathModel.paths.append(.partyList)
                }
            }
            .padding()
        }
    }
}


// MARK: - totalTime
func totalTime() -> String {
    
    
    let startTime = dummyPartys[0].startDate.hourMinute
    let stepCount = dummyPartys[0].stepList.count
//    let mediaCount = dummyPartys[0].stepList[stepCount-1].mediaList.count
//    let finishTime = dummyPartys[0].stepList[stepCount-1].mediaList[mediaCount-1].captureDate.hourMinute
    
    // 일단 강제 종료일 경우
    let allSteptime = (stepCount + 1) * dummyPartys[0].notiCycle
    
    let finishTime = Date(timeInterval: TimeInterval(allSteptime * 60), since: dummyPartys[0].startDate).hourMinute
    
    return "\(startTime) ~ \(finishTime)"
}

// MARK: - PartyTime List View
private struct ListView: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
      ]
    
    var body: some View {
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
                    
                    Text("\(dummyPartys[0].startDate.yearMonthdayweekDay)")
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
                    
                    Text(totalTime())
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
                    
                    LazyVGrid(columns: columns){
                        ForEach(dummyPartys[0].memberList!, id: \.profileImage){ member in
                            
                            Circle()
                                .frame(width: 54, height: 54)
                            
                        }
                    }       
                }
            }
        }
    }
}


#Preview {
    PartyResultView()
        .environmentObject(PathModel())
}
