//
//  MigrationPlan.swift
//  MC2-OneShot
//
//  Created by 김민준 on 6/16/24.
//

import SwiftData

enum OneShotMigrationPlan: SchemaMigrationPlan {
    
    /// Migration에서 사용할 스키마 종류
    static var schemas: [any VersionedSchema.Type] {
        [OneShotSchemaV1.self, OneShotSchemaV2.self]
    }
    
    /// 어떤 데이터를 마이그레이션 할 것인지 정의
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    /// V1 to V2 마이그레이션
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: OneShotSchemaV1.self,
        toVersion: OneShotSchemaV2.self
    )
}
