//
//  Helper+Image.swift
//  MC2-OneShot
//
//  Created by 정혜정 on 5/27/24.
//

import SwiftUI

extension Image {
    func flipHorizontally() -> Image {
        guard let uiImage = UIImage(named: "yourImage") else {
            return self
        }
        
        // UIImage를 CGImage로 변환
        guard let cgImage = uiImage.cgImage else {
            return self
        }
        
        // 좌우 반전을 위한 CGAffineTransform 설정
        let flippedCGImage = cgImage.copy(flippingHorizontallyWithTopLeftOrigin: true)
        
        // CGImage를 UIImage로 다시 변환
        let flippedUIImage = UIImage(cgImage: flippedCGImage, scale: uiImage.scale, orientation: uiImage.imageOrientation)
        
        return Image(uiImage: flippedUIImage)
    }
}
