//
//  PersistentDataInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import Foundation

protocol PersistentDataServiceInterface {
    func fetchPartys() -> [Party]
    func currentSteps() -> [Step]
    func savePhoto(_ photo: CapturePhoto)
}
