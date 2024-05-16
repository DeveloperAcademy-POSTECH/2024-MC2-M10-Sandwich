//
//  PartyResultVIew.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyResultView: View {
    
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
                
            ListView()
            
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
//    let rows = [
//        GridItem(.flexible())
//    ]
    
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
                    
                    LazyHGrid(rows: [GridItem(.flexible())]){
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


//// MARK: - ListView
//private struct ListView: View {
//    
//    @State private var searchText = ""
//    
//    var body: some View {
//        List(dummyPartys) { party in
//            ListCellView(
//                title: party.title,
//                captureDate: party.startDate,
//                isLive: party.isLive,
//                stepCount: party.stepList.count,
//                notiCycle: party.notiCycle
//            )
//            .swipeActions {
//                Button {
//                    // TODO: 술자리 데이터 삭제 Alert 출력
//                } label: {
//                    Text("삭제하기")
//                }
//                .tint(.red)
//            }
//        }
//        .searchable(
//            text: $searchText,
//            prompt: "술자리를 검색해보세요"
//        )
//        .listStyle(.plain)
//        .padding(.top, 8)
//        .padding(.bottom, 16)
//    }
//}

//
//// MARK: - ListCellView
//private struct ListCellView: View {
//    
//    let thumbnail: String
//    let title: String
//    let captureDate: Date
//    let isLive: Bool
//    let stepCount: Int
//    let notiCycle: Int
//    
//    var body: some View {
//        HStack {
//            Image(systemName: "wineglass.fill")
//                .resizable()
//                .frame(width: 68, height: 68)
//                .clipShape(RoundedRectangle(cornerRadius: 7.5))
//            
//            Spacer()
//                .frame(width: 8)
//            
//            VStack(alignment: .leading, spacing: 6) {
//                Text(title)
//                    .pretendard(.bold, 17)
//                    .foregroundStyle(.shotFF)
//                
//                Text("\(captureDate.yearMonthDay)")
//                    .pretendard(.regular, 14)
//                    .foregroundStyle(.shot6D)
//            }
//            
//            Spacer()
//            
//            VStack(spacing: 6) {
//                PartyStateInfoLabel(
//                    stateInfo: isLive ? .live : .end,
//                    stepCount: stepCount
//                )
//                
//                Text("\(notiCycle)min")
//                    .pretendard(.regular, 14)
//                    .foregroundStyle(.shot6D)
//            }
//        }
//    }
//}

#Preview {
    PartyResultView()
}
