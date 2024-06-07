//
//  PhotoSaveService.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/7/24.
//

import UIKit
import Photos

// MARK: - PhotoSaveService

struct PhotoSaveService: PhotoSaveServiceInterface {
    
    
    
    typealias SaveResult = Result<Void, SaveError>
    
    /// 사진 저장 에러 케이스
    enum SaveError: Error {
        case generalError
        case permissionDenied
    }
}

// MARK: - Protocol Implement

extension PhotoSaveService {
    
    /// 전체 사진을 저장합니다.
    func saveAllPhotos(_ photos: [CapturePhoto]) async -> SaveResult {
        for photo in photos {
            let result = await requestSavePhotoLibrary(photo.image)
            switch result {
            case .success(): continue
            case .failure(let error): return .failure(error)
            }
        }
        
        return .success(())
    }

    /// 현재 사진을 저장합니다.
    func saveCurrentPhoto(_ photo: CapturePhoto) async -> SaveResult {
        return await requestSavePhotoLibrary(photo.image)
    }
}

// MARK: - PHPhoto

extension PhotoSaveService {
    
    /// PHPhotoLibrary에 저장을 요청합니다.
    private func requestSavePhotoLibrary(_ image: UIImage) async -> SaveResult {
        
        // 1. 앨범 사용 권한 인증
        let status = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
        guard status == .authorized else {
            return .failure(.permissionDenied)
        }
        
        // 2. 사진 추가 요청
        do {
            try await PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                request.creationDate = .now
            }
        } catch {
            return .failure(.generalError)
        }
        
        return .success(())
    }
}
