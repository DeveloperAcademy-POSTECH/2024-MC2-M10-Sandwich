//
//  PartyListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyListView: View {
    var party: Party = Party(title: "포항공대애애앵", startDate: Date(), notiCycle: 30)
    @State private var isFinishPopupPresented = false
    @State private var isMemberPopupPresented = false
    @EnvironmentObject private var pathModel: PathModel
    
    var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Text(party.title)
                            .pretendard(.bold, 25)
                            .foregroundStyle(.shotFF)
                        Spacer()
                        Button {
                            isMemberPopupPresented.toggle()
                        } label: {
                             Image(systemName: "circle")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundStyle(.shotFF)
                        }
                    }
                    .padding(.top, 3)
                    .padding(.bottom, 8)
                    .padding(.horizontal, 16)
                    
                    ScrollView {
                        ForEach(Array(dummyParties[0].stepList.enumerated()), id: \.offset) { index, step in
                            
                            StepCell(index: index, step: step)
                        }
                        .padding(16)
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button(action: {
                                isFinishPopupPresented = true
                                // FinishPopupView()
                            }, label: {
                                if isFinishPopupPresented == false {
                                    Text("술자리 종료")
                                        .pretendard(.bold, 16.5)
                                        .foregroundStyle(.shotGreen)
                                } else {
                                    Image(systemName: "text.bubble")
                                        .pretendard(.bold, 16.5)
                                        .foregroundStyle(.shotGreen)
                                }
                            })
                            .fullScreenCover(isPresented: $isFinishPopupPresented) {
                                FinishPopupView(isFinishPopupPresented: $isFinishPopupPresented)
                                    .foregroundStyle(.shotFF)
                                    .presentationBackground(.black.opacity(0.7))
                            }
                            .transaction { transaction in
                                transaction.disablesAnimations = true
                            }
                        }
                    }
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .fullScreenCover(isPresented: $isMemberPopupPresented) {
                MemberPopupView(isMemberPopupPresented: $isMemberPopupPresented)
                    .foregroundStyle(.shotFF)
                    .presentationBackground(.black.opacity(0.7))
            }
            .transaction { transaction in
                transaction.disablesAnimations = true
            }
    }
}

struct StepCell: View {
    var index: Int
    var step: Step
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        Text("STEP_")
                            .pretendard(.bold, 22)
                            .foregroundStyle(.shotC6)
                        
                        Text("0\(index+1)")
                            .pretendard(.bold, 22)
                            .foregroundStyle(.shotGreen)
                    }
                    
                    HStack(spacing: 0) {
                        Text(step.mediaList[0].captureDate.yearMonthDayNoSpace)
                            .pretendard(.regular, 14)
                            .foregroundStyle(.shotCE)
                        
                        Rectangle()
                            .foregroundStyle(.shot33)
                            .frame(width: 2, height: 10)
                            .cornerRadius(10)
                            .padding(.horizontal, 6)
                        
                        Text(step.mediaList[0].captureDate.aHourMinute)
                            .pretendard(.regular, 14)
                            .foregroundStyle(.shotCE)
                        
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Button(action: {}, label: {
                    ZStack {
                        Image(.icnSave)
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .frame(width: 14, height: 18)
                            .pretendard(.semiBold, 16)
                            .foregroundStyle(.shotC6)
                    }
                }
                       
                )
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 15) {
                    ForEach(1...3, id: \.self) { index in
                        VStack {
                            Rectangle()
                                .foregroundStyle(.shotBlue)
                                .frame(width: 361, height: 361)
                                .cornerRadius(10)
                            
                            DotsView(selectedIndex: index)
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .padding(.top, 20)
        }
    }
}

struct DotsView: View {
    let selectedIndex: Int
    
    var body: some View {
        HStack(spacing: 5) {
            ForEach(1...3, id: \.self) { dotIndex in
                Circle()
                    .frame(width: 10, height: 10)
                    .padding(.horizontal, 5)
                    .foregroundColor(dotIndex == selectedIndex ? Color.shotC6 : Color.shot2D)
            }
        }
        .scrollTransition(.animated, axis: .horizontal) { content, phase in
            content
                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
        }
    }
}

// 더미데이터
let dummyParties: [Party] = [
    Party(
        title: "Birthday Bash",
        startDate: Date(),
        notiCycle: 7,
        stepList: [Step(mediaList: [Media(fileData: "photo1.jpg", captureDate: Date()), Media(fileData: "photo2.jpg", captureDate: Date())]),
                   Step(mediaList: [Media(fileData: "photo3.jpg", captureDate: Date()+30), Media(fileData: "photo4.jpg", captureDate: Date()+30)])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member1.jpg"), Member(profileImage: "member2.jpg")],
        comment: "Looking forward to it!"
    ),
    Party(
        title: "Office Party",
        startDate: Date(),
        notiCycle: 3,
        stepList: [Step(mediaList: [Media(fileData: "photo3.jpg", captureDate: Date()), Media(fileData: "photo4.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member3.jpg"), Member(profileImage: "member4.jpg")],
        comment: nil
    ),
    Party(
        title: "New Year Celebration",
        startDate: Date(),
        notiCycle: 10,
        stepList: [Step(mediaList: [Media(fileData: "photo5.jpg", captureDate: Date()), Media(fileData: "photo6.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member5.jpg"), Member(profileImage: "member6.jpg")],
        comment: "Happy New Year!"
    ),
    Party(
        title: "Summer BBQ",
        startDate: Date(),
        notiCycle: 14,
        stepList: [Step(mediaList: [Media(fileData: "photo7.jpg", captureDate: Date()), Media(fileData: "photo8.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member7.jpg"), Member(profileImage: "member8.jpg")],
        comment: "Can't wait for the BBQ!"
    ),
    Party(
        title: "Halloween Party",
        startDate: Date(),
        notiCycle: 5,
        stepList: [Step(mediaList: [Media(fileData: "photo9.jpg", captureDate: Date()), Media(fileData: "photo10.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member9.jpg"), Member(profileImage: "member10.jpg")],
        comment: "Spooky!"
    ),
    Party(
        title: "Christmas Party",
        startDate: Date(),
        notiCycle: 25,
        stepList: [Step(mediaList: [Media(fileData: "photo11.jpg", captureDate: Date()), Media(fileData: "photo12.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member11.jpg"), Member(profileImage: "member12.jpg")],
        comment: "Merry Christmas!"
    ),
    Party(
        title: "Graduation Party",
        startDate: Date(),
        notiCycle: 12,
        stepList: [Step(mediaList: [Media(fileData: "photo13.jpg", captureDate: Date()), Media(fileData: "photo14.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member13.jpg"), Member(profileImage: "member14.jpg")],
        comment: "Congratulations to all graduates!"
    ),
    Party(
        title: "Anniversary Party",
        startDate: Date(),
        notiCycle: 30,
        stepList: [Step(mediaList: [Media(fileData: "photo15.jpg", captureDate: Date()), Media(fileData: "photo16.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member15.jpg"), Member(profileImage: "member16.jpg")],
        comment: "Happy Anniversary!"
    ),
    Party(
        title: "Farewell Party",
        startDate: Date(),
        notiCycle: 8,
        stepList: [Step(mediaList: [Media(fileData: "photo17.jpg", captureDate: Date()), Media(fileData: "photo18.jpg", captureDate: Date())])],
        isLive: false,
        isShutdown: true,
        memberList: [Member(profileImage: "member17.jpg"), Member(profileImage: "member18.jpg")],
        comment: "Goodbye and good luck!"
    ),
    Party(
        title: "Welcome Party",
        startDate: Date(),
        notiCycle: 6,
        stepList: [Step(mediaList: [Media(fileData: "photo19.jpg", captureDate: Date()), Media(fileData: "photo20.jpg", captureDate: Date())])],
        isLive: true,
        isShutdown: false,
        memberList: [Member(profileImage: "member19.jpg"), Member(profileImage: "member20.jpg")],
        comment: "Welcome to the team!"
    )
]


#Preview {
    PartyListView(party: Party(title: "포항공대대애앵앵", startDate: Date(), notiCycle: 30))
}
