//
//  ImageModalTest.swift
//  MC2-OneShot
//
//  Created by Simmons on 5/17/24.
//

import SwiftUI

struct ImageModalView: View {
    
    @ObservedObject var viewManager = CameraViewManager()
    
    var body: some View {
        VStack {
            ScrollView {
                VStack {
                    ForEach(viewManager.arr, id: \.self) { data in
                        if let image = UIImage(data: data) {
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
        .onAppear {
            viewManager.configure()  // Ensure the camera manager is configured when the view appears
        }
    }
}
    
//    func saveImageToGallery() {
//        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
//        // 이미지 저장 후 모달 닫기
//        isPresented = false
//    }
//}



//#Preview {
//    ImageModalView()
//}

ForEach(viewManager.arr, id: \.self) { data in
    if let image = UIImage(data: data) {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .cornerRadius(10)
    }
}
