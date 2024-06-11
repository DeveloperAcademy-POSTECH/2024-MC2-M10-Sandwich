//
//  FooterInfo.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/7/24.
//

import SwiftUI

// MARK: - FooterInfo

struct FooterInfo: View {
    
    let symbol: SFSymbol
    let content: String
    
    var body: some View {
        HStack {
            Image(symbol: symbol)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 14, height: 14)
            
            Text(content)
                .pretendard(.regular, 12)
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    FooterInfo(
        symbol: .bolt,
        content: "플래시 버튼입니다!"
    )
}
#endif
