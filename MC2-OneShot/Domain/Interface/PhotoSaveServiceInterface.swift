//
//  PhotoSaveServiceInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/7/24.
//

import Foundation

protocol PhotoSaveServiceInterface {
    
    associatedtype SaveError: Error
    
    typealias SaveResult = Result<Void, SaveError>
    
    // func saveAllPhotos(_ photos: [CapturePhoto]) async -> SaveResult
    func saveCurrentPhoto(_ photo: CapturePhoto) async -> SaveResult
}
