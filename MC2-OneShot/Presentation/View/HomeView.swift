//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI
import SwiftData

// MARK: - HomeView

struct HomeView: View {
    
    @State private(set) var partyUseCase: PartyUseCase
    
    @StateObject private var homePathModel: HomePathModel = .init()
    
    @State private var isPartySetViewPresented = false
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        NavigationStack(path: $homePathModel.paths) {
            VStack(alignment: .leading) {
                HeaderView()
                ListView()
                ActionButton(
                    title: partyUseCase.state.isPartyLive ? "사진 찍으러 가기" : "술자리 생성하기",
                    buttonType: partyUseCase.state.isPartyLive ? .popupfinish : .primary
                ) {
                    partyUseCase.state.isPartyLive ?
                    partyUseCase.presentCameraView(to: true) :
                    isPartySetViewPresented.toggle()
                }
                .padding(.horizontal, 16)
            }
            .homePathDestination()
            .sheet(isPresented: $isPartySetViewPresented) {
                PartySetView(isPartySetViewPresented: $isPartySetViewPresented)
            }
        }
        .fullScreenCover(isPresented: $state.isCameraViewPresented) {
            PartyCameraView(cameraUseCase: CameraUseCase(cameraService: CameraService()))
        }
        .environment(partyUseCase)
        .environmentObject(homePathModel)
        .onAppear {
            partyUseCase.initialSetup()
        }
    }
}

// MARK: - HeaderView

private struct HeaderView: View {
    
    @EnvironmentObject private var homePathModel: HomePathModel
    
    var body: some View {
        HStack{
            Spacer()
            Button {
                homePathModel.paths.append(.searchList)
            } label: {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.shotFF)
                    .padding(.trailing, 16)
            }
        }
        
        Image(.appLogo)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(height: 35)
            .padding(.leading, 16)
            .padding(.top, 12)
            .padding(.bottom, 4)
    }
}

// MARK: - ListView

private struct ListView: View {
    
    @Query private var partys: [Party]
    
    @State private var isFirstInfoVisible = true
    
    var body: some View {
        ZStack {
            Image(.firstInfo)
                .padding(.bottom, 48)
                .opacity(partys.isEmpty ? 1 : 0)
            
            TableListView(isFirstInfoVisible: $isFirstInfoVisible)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let modelContext = MockModelContainer.mockModelContainer.mainContext
    
    return HomeView(
        partyUseCase: PartyUseCase(
            dataService: PersistentDataService(modelContext: modelContext),
            notificationService: NotificationService()
        )
    )
    .environmentObject(HomePathModel())
    .modelContainer(MockModelContainer.mockModelContainer)
}
#endif
