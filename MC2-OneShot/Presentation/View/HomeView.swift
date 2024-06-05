//
//  HomeView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

// MARK: - HomeView

struct HomeView: View {
    
    @State private(set) var partyUseCase: PartyUseCase
    @State private var homePathModel: HomePathModel = .init()
    @State private var isPartySetViewPresented = false
    
    var body: some View {
        @Bindable var state = partyUseCase.state
        NavigationStack(path: $homePathModel.paths) {
            VStack(alignment: .leading) {
                HeaderView()
                ListView()
                PartyButton(isPartySetViewPresented: $isPartySetViewPresented)
            }
            .homePathDestination()
            .sheet(isPresented: $isPartySetViewPresented) { PartySetView() }
        }
        .fullScreenCover(isPresented: $state.isCameraViewPresented) { PartyCameraView() }
        .environment(partyUseCase)
        .environment(homePathModel)
        .onAppear{ partyUseCase.initialSetup() }
    }
}

// MARK: - HeaderView

private struct HeaderView: View {
    
    @Environment(HomePathModel.self) private var homePathModel
    
    var body: some View {
        HStack {
            Spacer()
            Button {
                homePathModel.paths.append(.searchList)
            } label: {
                Image(symbol: .magnifyingglass)
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
            .padding(.top, 12)
            .padding(.bottom, 4)
            .padding(.leading, 16)
    }
}

// MARK: - ListView

private struct ListView: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    
    var body: some View {
        ZStack {
            Image(.firstInfo)
                .padding(.bottom, 48)
                .opacity(partyUseCase.partys.isEmpty ? 1 : 0)
            
            TableListView()
        }
    }
}

// MARK: - PartyButton

private struct PartyButton: View {
    
    @Environment(PartyUseCase.self) private var partyUseCase
    @Binding private(set) var isPartySetViewPresented: Bool
    
    var body: some View {
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
}

// MARK: - Preview

#if DEBUG
#Preview {
    let modelContext = MockModelContainer.mock.mainContext
    
    return HomeView(
        partyUseCase: PartyUseCase(
            dataService: PersistentDataService(modelContext: modelContext),
            notificationService: NotificationService()
        )
    )
    .environment(HomePathModel())
    .modelContainer(MockModelContainer.mock)
}
#endif
