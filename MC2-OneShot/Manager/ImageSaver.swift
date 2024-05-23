//
//  ImageSaver.swift
//  MC2-OneShot
//
//  Created by KimYuBin on 5/22/24.
//

import SwiftUI
import Photos

class ImageSaver {
    enum SaveError: Error {
        case generalError
        case permissionDenied
    }
    
    func saveImage(_ image: UIImage, completion: @escaping (Result<Void, SaveError>) -> Void) {
        PHPhotoLibrary.requestAuthorization { status in
            guard status == .authorized else {
                completion(.failure(.permissionDenied))
                return
            }
            
            PHPhotoLibrary.shared().performChanges {
                let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                request.creationDate = Date()
            } completionHandler: { success, error in
                DispatchQueue.main.async {
                    if success {
                        completion(.success(()))
                    } else {
                        completion(.failure(.generalError))
                    }
                }
            }
        }
    }
}
