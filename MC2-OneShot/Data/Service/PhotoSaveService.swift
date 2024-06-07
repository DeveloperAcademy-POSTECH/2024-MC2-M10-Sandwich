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
    
//    func saveAllPhotos(_ photos: [CapturePhoto], completion: SaveResult) async {
//        
//    }
//    
    func saveCurrentPhoto(_ photo: CapturePhoto) async -> SaveResult {
        return await requestSavePhotoLibrary(photo.image)
    }
    
//    /// 전체 사진을 저장합니다.
//    func saveAllPhotos(
//        _ photos: [CapturePhoto],
//        completion: @escaping (Result<Void, SaveError>) -> Void
//    ) {
//        for photo in photos {
//            requestSavePhotoLibrary(photo.image) { result in
//                switch result {
//                case .success:
//                    print("🎞️ 전체 사진 저장 완료")
//                    
//                case .failure(let error):
//                    print("❌ 전체 사진 저장 실패: \(error.localizedDescription)")
//                }
//            }
//        }
//    }
//    
//    /// 현재 사진을 저장합니다.
//    func saveCurrentPhoto(
//        _ photo: CapturePhoto,
//        completion: @escaping (Result<Void, SaveError>) -> Void
//    ) {
//        requestSavePhotoLibrary(photo.image) { result in
//            switch result {
//            case .success:
//                print("🎞️ 현재 사진 저장 완료")
//                
//            case .failure(let error):
//                print("❌ 현재 사진 저장 실패: \(error.localizedDescription)")
//            }
//        }
//    }
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
    
//    /// PHPhotoLibrary에 저장을 요청합니다.
//    private func requestSavePhotoLibrary(
//        _ image: UIImage,
//        completion: @escaping (Result<Void, SaveError>) -> Void
//    ) {
//        PHPhotoLibrary.requestAuthorization { status in
//            guard status == .authorized else {
//                completion(.failure(.permissionDenied))
//                return
//            }
//            
//            PHPhotoLibrary.shared().performChanges {
//                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
//                request.creationDate = Date()
//            } completionHandler: { success, error in
//                DispatchQueue.main.async {
//                    if success {
//                        completion(.success(()))
//                    } else {
//                        completion(.failure(.generalError))
//                    }
//                }
//            }
//        }
//    }
// }
