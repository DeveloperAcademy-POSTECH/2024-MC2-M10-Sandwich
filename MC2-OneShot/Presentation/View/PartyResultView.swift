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
    
    var body: some View {
        
        VStack{
            ZStack{
                if ((partys.last?.isShutdown) == true){
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            isHelpMessagePresented.toggle()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .foregroundColor(.shot33)
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
            }
            .padding(.top,12)
            
            // 상단 STEP
            // TODO: - 병뚜껑 색 바꿔야함
            VStack{
                ZStack{
                    Image("Greenbottle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                    
                    Image(systemName: "checkmark")
                        .foregroundColor(.shot00)
                }
                
                HStack{
                    Text("STEP ")
                        .foregroundColor(.shotFF)
                        .pretendard(.bold, 32)
                    
                    Text("\((partys.last?.stepList.count ?? 1).intformatter)")
                        .foregroundColor(.shotGreen)
                        .pretendard(.bold, 32)
                    
                }
                
                HStack{
                    // preview crash 
//                    Text("30min")
                    Text("\((partys.last?.notiCycle)!)min")
                        .foregroundStyle(.shotC6)
                        .pretendard(.bold, 17)
                }
                
            }
            .padding(.top,20)
            
            ListView()
            
            HStack(spacing: 8) {
                ActionButton(
                    title: "홈으로 돌아가기",
                    buttonType: .secondary
                ) {
                    isPartyResultViewPresented = false
                }
                
                ActionButton(
                    title: "술자리 다시보기",
                    buttonType: .primary
                ) {
                    isPartyResultViewPresented = false
                    homePathModel.paths.append(.partyList(party: partys.last!))
                }
            }
            .padding()
        }
        .navigationBarBackButtonHidden(true)
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
                        Text("술자리")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotC6)
                        
                    }
                    .padding(.leading, 24)
                    
                    HStack{
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text(partys.last?.title ?? "시몬스바보")
                            .pretendard(.bold, 16)
                            .foregroundStyle(.shotFF)
                            .padding(.leading,8)
                    }
                    
                }
                
                VStack(alignment: .leading){
                    HStack{
                        Text("날짜")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotC6)
                        
                    }
                    .padding(.leading, 24)
                    
                    HStack{
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text((partys.last?.startDate ?? Date()).yearMonthdayweekDay)
                            .pretendard(.bold, 16)
                            .foregroundStyle(.shotFF)
                            .padding(.leading,8)
                    }
                    
                }
                
                VStack(alignment: .leading){
                    HStack{
                        Text("진행시간")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotC6)
                        
                    }
                    .padding(.leading, 24)
                    
                    HStack{
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text(totalTime())
                            .pretendard(.bold, 16)
                            .foregroundStyle(.shotFF)
                            .padding(.leading,8)
                    }
                }
            }
            
            Section{
                VStack(alignment: .leading){
                    HStack{
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotC6)
                            .padding(.leading,8)
                        
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
