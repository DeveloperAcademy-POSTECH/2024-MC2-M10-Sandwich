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
    
    @State private var isHelpMessagePresented = false
    
    /// 현재 PartyResultView가 어떤 View에서 Present 되었는지 확인하는 변수
    let rootView: RootView
    
    enum RootView {
        case list
        case camera
    }
    
    /// 현재 파티를 반환합니다.
    private var currentParty: Party {
        if let lastParty = partyUseCase.partys.last { return lastParty }
        fatalError("결과 화면을 표시 할 Party 데이터가 없습니다.")
    }
    
    var body: some View {
        VStack {
            ZStack {
                if currentParty.isShutdown {
                    HStack {
                        Spacer()
                        Button {
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
                    .transaction { $0.disablesAnimations = true }
                }
            }
            .padding(.top, 12)
            
            // 상단 STEP
            VStack(spacing: 0) {
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
                    
                    Text("\(currentParty.stepList.count.intformatter)")
                        .foregroundColor(.shotGreen)
                        .pretendard(.bold, 32)
                    
                }
                
                HStack{
                    Text("\(currentParty.notiCycle)min")
                        .foregroundStyle(.shotC6)
                        .pretendard(.bold, 17)
                }
                
            }
            .padding(.top,28)
            
            ResultViewList(currentParty: currentParty)
            
            if currentParty.memberList.isEmpty {
                MemberResultView(currentParty: currentParty)
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
                        homePathModel.paths.append(.partyList(party: currentParty))
                    }
                }
            }
            .padding()
        }
        .scrollDisabled(true)
        .navigationBarBackButtonHidden(true)
        .onAppear {
            currentParty.isLive = false
            if let lastStep = currentParty.sortedStepList.last {
                if lastStep.mediaList.isEmpty {
                    modelContext.delete(lastStep)
                }
            }
        }
    }
}

// MARK: - ResultViewList

private struct ResultViewList: View {
    
    private(set) var currentParty: Party
    
    var body: some View {
        List {
            Section {
                ResultViewListViewCell(
                    title: "술자리",
                    content: currentParty.title
                )
                
                ResultViewListViewCell(
                    title: "날짜",
                    content: currentParty.startDate.yearMonthdayweekDay
                )
                
                ResultViewListViewCell(
                    title: "진행시간",
                    content: totalTime
                )
            }
        }
    }
    
    /// 파티를 진행한 전체 시간 문자열을 반환합니다.
    private var totalTime: String {
        let startTime = currentParty.startDate.hourMinute
        let stepCount = currentParty.stepList.count
        let allSteptime = stepCount + 1 * currentParty.notiCycle
        
        // 자동 종료된 경우
        if currentParty.isShutdown {
            let finishTime = Date(timeInterval: TimeInterval(allSteptime * 60), since: currentParty.startDate).hourMinute
            return "\(startTime) ~ \(finishTime)"
        } else { // 직접 종료한 경우
            let finishTime = Date().hourMinute
            return "\(startTime) ~ \(finishTime)"
        }
    }
}

// MARK: - ResultListViewCell

private struct ResultViewListViewCell: View {
    
    let title: String
    let content: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .pretendard(.bold, 14)
                .foregroundColor(.shotC6)
                .padding(.leading, 24)
            
            HStack {
                Circle()
                    .frame(width: 8, height: 8)
                    .foregroundColor(.shotGreen)
                
                Text(content)
                    .pretendard(.bold, 16)
                    .foregroundStyle(.shotFF)
                    .padding(.leading,8)
            }
        }
    }
}

// MARK: - MemberResultView

private struct MemberResultView: View {
    
    private(set) var currentParty: Party
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Circle()
                            .frame(width: 8, height: 8)
                            .foregroundColor(.shotGreen)
                        
                        Text("함께한 사람들")
                            .pretendard(.bold, 14)
                            .foregroundColor(.shotFF)
                            .padding(.leading,8)
                    }
                    
                    LazyVGrid(columns: columns, spacing: 18) {
                        ForEach(currentParty.memberList) { member in
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

// MARK: - Preview

#if DEBUG
#Preview {
    PartyResultView(rootView: .camera)
        .environment(
            PartyUseCase(
                dataService: PersistentDataService(modelContext: MockModelContainer.mock.mainContext),
                notificationService: NotificationService()
            )
        )
        .environment(HomePathModel())
}
#endif

