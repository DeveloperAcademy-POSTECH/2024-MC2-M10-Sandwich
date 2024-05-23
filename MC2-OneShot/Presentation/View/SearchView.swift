//
//  SearchView.swift
//  MC2-OneShot
//
//  Created by p_go.ne on 5/18/24.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var searchText = ""
    
    @Environment(\.presentationMode) var presentationMode
    
//    init() {
//            let appearance = UINavigationBarAppearance()
//    appearance.configureWithOpaqueBackground()
//    appearance.backgroundColor = UIColor.systemBackground
//    appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
//    appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
//    
//    // Set the color of the back button arrow
//    UINavigationBar.appearance().tintColor = .red
//    
//    // Apply the appearance settings
//    UINavigationBar.appearance().standardAppearance = appearance
//    UINavigationBar.appearance().compactAppearance = appearance
//    UINavigationBar.appearance().scrollEdgeAppearance = appearance
//        }
//    
    var body: some View {
        VStack {
            Group{
                if searchText.isEmpty {
                    Image(.imgLogo)
                        .padding(.bottom, 60)
                        .opacity(0.1)
    //                Text("찾고싶은 술자리 이름을 검색해주세요")
    //                    .pretendard(.semiBold, 17)
    //                    .foregroundStyle(.shot33)
                    
                  
                } else {
                    ListView(searchText: $searchText)
                }
            }.searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "기억하고 싶은 술자리를 검색해 보세요"
                
            )
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.shotFF)
                }
            }
        }
        .navigationTitle("검색하기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - ListView
private struct ListView: View {
    
    /// 리스트에 보여질 첫번째 썸네일 데이터를 반환합니다.
    func firstThumbnail(_ party: Party) -> Data {
        guard let firstStep = party.stepList.first,
              let firstMedia = firstStep.mediaList.first else {
            // print("썸네일 반환에 실패했습니다.")
            return Data()
        }
        
        return firstMedia.fileData
    }
    
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    @Query private var partys: [Party]
    @Binding var searchText: String
    
    var searchPartys: [Party]{
        partys.filter {
            $0.title.contains(searchText)
        }
    }
    var body: some View {
        List(searchPartys) { party in
            ListCellView(
                thumbnail: firstThumbnail(party),
                title: party.title,
                captureDate: party.startDate,
                isLive: party.isLive,
                stepCount: party.stepList.count,
                notiCycle: party.notiCycle
            )
            .onTapGesture {
                homePathModel.paths.append(.partyList(party: party))
            }
            .swipeActions {
                Button {
                    // TODO: 술자리 데이터 삭제 Alert 출력
                } label: {
                    Text("삭제하기")
                }
                .tint(.red)
            }
        }
        .listStyle(.plain)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

// MARK: - ListCellView
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
//            Image(.test)
//                .resizable()
//                .frame(width: 68, height: 68)
//                .clipShape(RoundedRectangle(cornerRadius: 7.5))
//            
//            Spacer()
//                .frame(width: 12)
//            
//            VStack(alignment: .leading, spacing: 4) {
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
//            VStack(spacing: 4) {
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

// MARK: - PartyStateInfoLabel
//private struct PartyStateInfoLabel: View {
//    
//    /// 술자리 상태를 나타내는 열거형
//    enum StateInfo: String {
//        case live
//        case end
//    }
//    
//    let stateInfo: StateInfo
//    let stepCount: Int
//    
//    var body: some View {
//        Text(stateInfo == .live ? "LIVE" : "STEP_\(stepCount)")
//            .frame(width: 76, height: 22)
//            .pretendard(.bold, 14)
//            .background(stateInfo == .live ? .shotGreen : .shot33)
//            .foregroundStyle(stateInfo == .live ? .shot00 : .shotD8)
//            .clipShape(RoundedRectangle(cornerRadius: 12))
//    }
//}

#Preview {
    SearchView()
}
