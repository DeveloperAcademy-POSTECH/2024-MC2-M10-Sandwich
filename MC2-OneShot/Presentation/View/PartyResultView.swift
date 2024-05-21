//
//  PartyResultVIew.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct PartyResultView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    @Query private var partys: [Party]
    @State private var isHelpMessagePresented = false
    @Binding var isPartyResultViewPresented: Bool
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party {
        return partys.last ?? Party(title: "잘못된 파티", startDate: .now, notiCycle: 30)
    }
    
    var body: some View {
        VStack{
            if ((partys.last?.isShutdown) != nil){
                
                HStack{
                    Spacer()
                    
                    Button{
                        isHelpMessagePresented.toggle()
                    } label: {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.shotFF)
                    }
                }
                .padding(.trailing)
                .fullScreenCover(isPresented: $isHelpMessagePresented) {
                    ShutdownPopupView(isHelpMessagePresented: $isHelpMessagePresented)
                        .foregroundStyle(.shotFF)
                        .presentationBackground(.black.opacity(0.7))
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
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
                        
                        //                        Text("STEP \(dummyPartys[0].stepList.count)")
                        Text("STEP \(partys.last?.stepList.count ?? 3)")
                            .foregroundColor(.shot00)
                            .pretendard(.bold, 20)
                    }
                )
            
            VStack{
                //                Text("\(dummyPartys[0].title)")
                Text(partys.last?.title ?? "제목입니당")
                    .foregroundColor(.shotFF)
                    .pretendard(.extraBold, 20)
                
                if ((partys.last?.isShutdown) != nil){
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
                    isPartyResultViewPresented = false
                }
                
                ActionButton(
                    title: "그룹으로 이동",
                    buttonType: .primary
                ) {
                    isPartyResultViewPresented = false
                    homePathModel.paths.append(.partyList(party: partys.last!))
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            currentParty.isLive = false
        }
    }
}



// MARK: - PartyTime List View
private struct ListView: View {
    @Query private var partys: [Party]
    
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
                    
                    //                        Text("\(dummyPartys[0].startDate.yearMonthdayweekDay)")
                    Text((partys.last?.startDate ?? Date()).yearMonthdayweekDay)
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
                        ForEach(partys.last?.memberList ?? []){ member in
                            Circle()
                                .frame(width: 54, height: 54)
                            
                        }
                    }
                }
            }
        }
    }
    // MARK: - totalTime
    func totalTime() -> String {
        //    let startTime = dummyPartys[0].startDate.hourMinute
        //    let stepCount = dummyPartys[0].stepList.count
        //    //    let mediaCount = dummyPartys[0].stepList[stepCount-1].mediaList.count
        //    //    let finishTime = dummyPartys[0].stepList[stepCount-1].mediaList[mediaCount-1].captureDate.hourMinute
        //
        //    // 일단 강제 종료일 경우
        //    let allSteptime = (stepCount + 1) * dummyPartys[0].notiCycle
        //
        //    let finishTime = Date(timeInterval: TimeInterval(allSteptime * 60), since: dummyPartys[0].startDate).hourMinute
        //
        //    return "\(startTime) ~ \(finishTime)"
        
        let startTime = (partys.last?.startDate ?? Date()).hourMinute
        let stepCount = partys.last?.stepList.count ?? 3
        //    let mediaCount = dummyPartys[0].stepList[stepCount-1].mediaList.count
        //    let finishTime = dummyPartys[0].stepList[stepCount-1].mediaList[mediaCount-1].captureDate.hourMinute
        
        // 일단 강제 종료일 경우
        let allSteptime = (stepCount + 1) * (partys.last?.notiCycle ?? 60)
        
        let finishTime = Date(timeInterval: TimeInterval(allSteptime * 60), since: partys.last?.startDate ?? Date()).hourMinute
        
        return "\(startTime) ~ \(finishTime)"
    }
}


#Preview {
    PartyResultView(isPartyResultViewPresented: .constant(true))
        .environmentObject(CameraPathModel())
}
