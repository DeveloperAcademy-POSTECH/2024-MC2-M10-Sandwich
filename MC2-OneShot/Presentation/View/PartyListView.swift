//
//  PartyListView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartyListView: View {
    
    @State private var isFinishPopupPresented = false
    @State private var isMemberPopupPresented = false
    @State private var isPartyResultViewPresented = false
    @State private var isPartyEnd = false
    
    @Environment(\.presentationMode) var presentationMode
    
    let party: Party
    
    @Binding var isCameraViewPresented: Bool
    
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
                .padding(.bottom, 14)
                .padding(.horizontal, 16)
                .fullScreenCover(isPresented: $isMemberPopupPresented) {
                    MemberPopupView(isMemberPopupPresented: $isMemberPopupPresented)
                        .foregroundStyle(.shotFF)
                        .presentationBackground(.black.opacity(0.7))
                }
                .transaction { transaction in
                    transaction.disablesAnimations = true
                }
                
                Divider()
                
                ScrollView {
                    ForEach(Array(party.stepList.enumerated()), id: \.offset) { index, step in
                        StepCell(index: index, step: step)
                        
                        Divider()
                    }
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
                        .fullScreenCover(isPresented: $isFinishPopupPresented, onDismiss: {
                            if isPartyEnd {
                                isPartyResultViewPresented.toggle()
                            }
                        }, content: {
                            FinishPopupView(
                                isFinishPopupPresented: $isFinishPopupPresented,
                                isPartyEnd: $isPartyEnd
                            )
                            .foregroundStyle(.shotFF)
                            .presentationBackground(.black.opacity(0.7))
                        })
                        .transaction { transaction in
                            transaction.disablesAnimations = true
                        }
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
                .fullScreenCover(isPresented: $isPartyResultViewPresented) {
                    isCameraViewPresented = false
                } content: {
                    PartyResultView(isPartyResultViewPresented: $isPartyResultViewPresented)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct StepCell: View {
    var index: Int
    var step: Step
    
    @State private var visibleMediaIndex = 0
    @State private var captureDates: [Date] = []
    
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
                        Text(captureDates.isEmpty ? "" : captureDates[visibleMediaIndex].yearMonthDayNoSpace)
                            .pretendard(.semiBold, 14)
                            .foregroundStyle(.shotC6)
                            .opacity(0.4)
                        
                        Rectangle()
                            .foregroundStyle(.shot33)
                            .frame(width: 2, height: 10)
                            .cornerRadius(10)
                            .padding(.horizontal, 6)
                        
                        Text(captureDates.isEmpty ? "" : captureDates[visibleMediaIndex].aHourMinute)
                            .pretendard(.semiBold, 14)
                            .foregroundStyle(.shotC6)
                            .opacity(0.4)
                    }
                    .padding(.top, 4)
                }
                
                Spacer()
                
                Button(action: {}, label: {
                    ZStack {
                        Image(.icnSave)
                            .resizable()
                            .frame(width: 35, height: 35)
                        
                        Image(systemName: "square.and.arrow.up")
                            .resizable()
                            .frame(width: 16, height: 20)
                            .pretendard(.semiBold, 16)
                            .foregroundStyle(.shotC6)
                            .offset(y: -1)
                    }
                })
            }
            .padding(16)
            
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack {
                    ForEach(Array(step.mediaList.sorted(by: { $0.captureDate < $1.captureDate }).enumerated()), id: \.offset) { index, media in
                        ZStack(alignment: .topTrailing) {
                            if let image = UIImage(data: media.fileData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: .infinity, height: 393)
                                    .cornerRadius(15)
                            }
                            
                            Text("\(index+1) / \(step.mediaList.count)")
                                .pretendard(.regular, 17)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .foregroundStyle(.shotFF)
                                .background(.black.opacity(0.5))
                                .cornerRadius(50)
                                .padding(.top, 16)
                                .padding(.trailing, 16)
                                .onAppear {
                                    captureDates.append(media.captureDate)
                                }
                        }
                        .onAppear {
                            visibleMediaIndex = index
                        }
                    }
                }
            }
            .scrollTargetLayout()
            .scrollTargetBehavior(.viewAligned)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    PartyListView(
        party: Party(title: "포항공대대애앵앵", startDate: Date(), notiCycle: 60),
        isCameraViewPresented: .constant(true)
    )
}
