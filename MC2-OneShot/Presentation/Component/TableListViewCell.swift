//
//  TableListViewCell.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/5/24.
//

import SwiftUI

// MARK: - TableListCellView

struct TableListCellView: View {
    
    let thumbnail: UIImage
    let title: String
    let captureDate: Date
    let isLive: Bool
    let stepCount: Int
    let notiCycle: Int
    
    var body: some View {
        HStack {
            Image(uiImage: thumbnail)
                .resizable()
                .frame(width: 68, height: 68)
                .clipShape(RoundedRectangle(cornerRadius: 7.5))
            
            Spacer()
                .frame(width: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .pretendard(.bold, 17)
                    .foregroundStyle(.shotFF)
                
                Text("\(captureDate.yearMonthDay)")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
            
            Spacer()
            
            VStack(spacing: 4) {
                TableListStateInfoLabel(
                    stateInfo: isLive ? .live : .end,
                    stepCount: stepCount
                )
                
                Text("\(notiCycle)min")
                    .pretendard(.regular, 14)
                    .foregroundStyle(.shot6D)
            }
        }
        .background(.shot00)
    }
}

// MARK: - TableListStateInfoLabel

private struct TableListStateInfoLabel: View {
    
    /// 술자리 상태를 나타내는 열거형
    enum StateInfo: String {
        case live
        case end
    }
    
    let stateInfo: StateInfo
    let stepCount: Int
    
    var body: some View {
        if stateInfo == .live {
            Text("LIVE")
                .pretendard(.bold, 14)
                .foregroundStyle(Color.shot00)
                .frame(width: 76, height: 22)
                .background(Color.shotGreen)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            HStack(spacing: 0) {
                Text("STEP ")
                    .foregroundStyle(Color.shotD8)
                
                Text("\(stepCount.intformatter)")
                    .foregroundStyle(Color.shotGreen)
            }
            .pretendard(.bold, 14)
            .frame(width: 76, height: 22)
            .background(Color.shot33)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    TableListCellView(
        thumbnail: UIImage(resource: .test),
        title: "테스트 제목",
        captureDate: .now,
        isLive: true,
        stepCount: 7,
        notiCycle: 30
    )
}
#endif
