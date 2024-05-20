//
//  testView.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/20/24.
//

import SwiftUI
import SwiftData

struct testView: View {
    @Query private var partys: [Party]
    
    @Binding var istestPresent: Bool
    var body: some View {
        VStack {
            ForEach(partys.last?.stepList.last?.mediaList ?? [] ) { data in
                if let image = UIImage(data: data.fileData) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(10)
                            }
                        }
                    }
    }
}
