//
//  PersistentDataInterface.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/2/24.
//

import Foundation

/// Domain - 영구 데이터 인터페이스
protocol PersistentDataServiceInterface {
    func isPartyLive() -> Bool
    func currentStep() -> Step?
    func fetchPartys() -> [Party]
    func createParty(_ party: Party)
    func deleteParty(_ party: Party)
    func deleteStep(_ step: Step)
    func savePhoto(_ photo: CapturePhoto)
}
