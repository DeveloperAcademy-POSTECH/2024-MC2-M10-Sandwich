//
//  PartyResultVIew.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

struct PartyResultView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Environment(HomePathModel.self) private var homePathModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var partys: [Party]
    @State private var isHelpMessagePresented = false
    
    let rootView: RootView
    
    enum RootView {
        case list
        case camera
    }
    
    /// 현재 파티를 반환합니다.
    var currentParty: Party? {
        let sortedParty = partys.sorted { $0.startDate < $1.startDate }
        return sortedParty.last
    }
    
    var body: some View {
        
        VStack{
            ZStack{
                if ((partys.lastParty?.isShutdown) == true){
                    
                    HStack{
                        Spacer()
                        
                        Button{
                            isHelpMessagePresented.toggle()
                        } label: {
                            Image(symbol: .exclamationmarkCircle)
                                .pretendard(.semiBold, 17)
                                .foregroundColor(.shotC6)
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
            VStack(spacing: 0){
                ZStack{
                    Image("Greenbottle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30,height: 30)
                    
                    Image(symbol: .checkmark)
                        .foregroundColor(.shot00)
                }
                .padding(.bottom, 4)
                
                HStack{
                    Text("STEP")
                        .foregroundColor(.shotFF)
                        .pretendard(.bold, 32)
                    
                    Text("\((partys.lastParty?.stepList.count ?? 1).intformatter)")
                        .foregroundColor(.shotGreen)
                        .pretendard(.bold, 32)
                    
                }
                
                HStack{
                    // preview crash
                    //                    Text("30min")
                    Text("\((partys.lastParty?.notiCycle)!)min")
                        .foregroundStyle(.shotC6)
                        .pretendard(.bold, 17)
                }
                
            }
            .padding(.top,28)
            
            ListView()
            
            if let currentParty = currentParty,
               let memberList = partys.lastParty?.memberList,
               !memberList.isEmpty {
                MemberResultView(party: currentParty)
                    .padding(.top, -20)
            }
            
            HStack(spacing: 8) {
                ActionButton(
                    title: "홈으로 돌아가기",
                    buttonType: .secondary
                ) {
                    rootView == .camera ?
                    partyUseCase.presentCameraView(to: false) :
                    partyUseCase.presentResultView(to: false)
                    NavigationHelper.popToRootView()
                }
                
                if rootView == .camera {
                    ActionButton(
                        title: "술자리 다시보기",
                        buttonType: .primary
                    ) {
                        partyUseCase.presentCameraView(to: false)
                        NavigationHelper.popToRootView()
                        homePathModel.paths.append(.partyList(party: partys.lastParty!))
                    }
                }
            }
            .padding()
        }
        .scrollDisabled(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            currentParty?.isLive = false
            
            if let lastParty = currentParty,
               let lastStep = lastParty.sortedStepList.last {
                
                if lastStep.mediaList.isEmpty {
                    modelContext.delete(lastStep)
                }
            }
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
                        
                        Text((partys.lastParty?.startDate ?? Date()).yearMonthdayweekDay)
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
        }
    }
    
    // MARK: - totalTime
    func totalTime() -> String {
        
        let startTime = (partys.lastParty?.startDate ?? Date()).hourMinute
        let stepCount = partys.lastParty?.stepList.count ?? 3
        
        let allSteptime = (stepCount + 1) * (partys.lastParty?.notiCycle ?? 60)
        
        // 자동 종료된 경우
        if ((partys.lastParty?.isShutdown) == true) {
            let finishTime = Date(timeInterval: TimeInterval(allSteptime * 60), since: partys.lastParty?.startDate ?? Date()).hourMinute
            return "\(startTime) ~ \(finishTime)"
        } else { // 직접 종료한 경우
            let finishTime = Date().hourMinute
            return "\(startTime) ~ \(finishTime)"
        }
    }
}

// MARK: - MemberResult View
private struct MemberResultView: View {
    
    var party: Party
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        List{
            Section{
                VStack(alignment: .leading, spacing: 0){
                    HStack{
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotFF)
                            .padding(.leading,8)
                        
                    }
                    
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(party.memberList, id: \.self) { member in
                            if let image = UIImage(data: member.profileImageData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .frame (width: 60, height: 60)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.top, 18)
                    .padding(.bottom, 8)
                }
            }
        }
    }
}


#Preview {
    PartyResultView(rootView: .camera)
        .environment(CameraPathModel())
}
