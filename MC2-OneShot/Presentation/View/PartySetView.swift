//
//  PartySetView.swift
//  MC2-OneShot
//
//  Created by 김민준 on 5/13/24.
//

import SwiftUI

struct PartySetView: View {
    @Binding var isPartySetViewPresented: Bool
    @EnvironmentObject private var pathModel: PathModel
    
    let rows = [
        GridItem(.flexible())
    ]
    
    let members : [String] = ["김민준","곽민준","오띵진","정혜정"]
    @State var titleText: String = ""
    var body: some View {
        
        VStack(alignment: .leading) {
            Form {
                Section {
                    TextField("제목", text: $titleText)
                }
                
                Section {
                    VStack(alignment: .leading){
                        Text("사람 추가")
                            .pretendard(.regular, 17)
                            .foregroundStyle(.shotFF)
                        Spacer()
                            .frame(height: 16)
                        
                        HStack(spacing: 24) {
                            ForEach(members, id: \.self) { member in
                                Circle()
                                    .frame (width: 60)
                            }
                            
                        }
                    }
                }
                .padding(10)

            }
            Spacer()
            ActionButton(title: "GO STEP!", buttonType: .primary) {
                isPartySetViewPresented.toggle()
                pathModel.paths.append(.partyCamera)
            }.padding(16)
        }
    }
}


#Preview {
    PartySetView(isPartySetViewPresented: .constant(true))
}
