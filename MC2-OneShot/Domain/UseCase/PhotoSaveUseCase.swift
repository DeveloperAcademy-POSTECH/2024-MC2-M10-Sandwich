//
//  PhotoSaveUseCase.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/7/24.
//

import Foundation

// MARK: - PhotoSaveUseCase

@Observable
final class PhotoSaveUseCase<PhotoSaveService: PhotoSaveServiceInterface> {
    
    private var photoSaveService: PhotoSaveService
    
    private(set) var state: State
    
    init(photoSaveService: PhotoSaveService) {
        self.photoSaveService = photoSaveService
        self.state = State()
    }
}

// MARK: - State Struct

extension PhotoSaveUseCase {
    
    @Observable
    final class State {
        var isPhotoSaved: Bool
        
        init(isPhotoSaved: Bool = false) {
            self.isPhotoSaved = isPhotoSaved
        }
    }
}

// MARK: - UseCase Method

extension PhotoSaveUseCase {
    
    /// 현재 사진을 저장합니다.
    func saveCurrentPhoto(_ photo: CapturePhoto) {
        Task {
            let result = await photoSaveService.saveCurrentPhoto(photo)
            switch result {
            case .success:
                state.isPhotoSaved = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.state.isPhotoSaved = false
                }
            case .failure(let error):
                print("사진 저장에 실패했습니다 : \(error.localizedDescription)")
            }
        }
    }
}
