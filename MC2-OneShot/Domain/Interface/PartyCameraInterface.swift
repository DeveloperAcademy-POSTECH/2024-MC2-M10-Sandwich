//
//  PartyCameraInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import SwiftUI

/// 카메라와 관련된 기능
protocol PartyCameraInterface {
    func requestPermission()
    func displayPreview() -> AnyView
    func capturePhoto()
    func fetchPhotoDataForSave() -> Data?
    func toggleFrontBack()
    func toggleFlashMode()
}
