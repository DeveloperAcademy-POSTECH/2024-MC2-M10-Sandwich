//
//  PartyListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyListView: View {
    let party: Party
    
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
                    ForEach(Array(party.stepList.enumerated()), id: \.offset) { index, step in
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
                        Text("STEP ")
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
                        Image(systemName: "square.and.arrow.down")
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
                    ForEach(Array(step.mediaList.sorted(by: { $0.captureDate < $1.captureDate }).enumerated()), id: \.offset) { index, media in
                        ZStack(alignment: .topTrailing) {
                            if let image = UIImage(data: media.fileData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 361, height: 361)
                                    .cornerRadius(10)
                            }
                            
                            Text("\(index+1) / \(step.mediaList.count)")
                                .pretendard(.regular, 12)
                                .padding(5)
                                .foregroundColor(.white)
                                .background(.black.opacity(0.5))
                                .cornerRadius(50)
                                .padding(.top, 15)
                                .padding(.trailing, 20)
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .padding(.top, 20)
            .padding(.bottom, 30)
        }
    }
}

#Preview {
    PartyListView(party: Party(title: "포항공대대애앵앵", startDate: Date(), notiCycle: 60))
}
