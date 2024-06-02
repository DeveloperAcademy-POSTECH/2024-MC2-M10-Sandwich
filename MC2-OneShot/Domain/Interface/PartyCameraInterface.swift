//
//  PartyCameraInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import Foundation

/// 카메라와 관련된 기능
protocol PartyCameraInterface {
    func capturePhoto()
    func savePhoto()
    func displayPreview()
    func toggleFrontBack()
    func toggleFlashMode()
}
