//
//  CameraServiceInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/1/24.
//

import SwiftUI
import Combine

/// Domain - 카메라 인터페이스
protocol CameraServiceInterface {
    func requestPermission()
    func displayPreview() -> AnyView
    func capturePhoto(photoDataPrepare: @escaping (CapturePhoto?) -> Void)
    func fetchPhotoDataForSave() -> CapturePhoto?
    func toggleFrontBack()
    func toggleFlashMode()
    func rotationAngle(orientation: UIDeviceOrientation) -> Angle
    func orientationChange() -> AnyPublisher<UIDeviceOrientation, Never>
    func generalAngle()
    func wideAngle()
}
