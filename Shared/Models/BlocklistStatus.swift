//
//  BlocklistStatus.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import SwiftData

@Model 
class BlocklistStatus {
    var blocklistId: UUID?
    var compiledSuccessfully: Bool?
    var errorsCount: Int64? = 0
    var httpCode: Int16? = 0
    var id: UUID?
    var overLimit: Bool?
    var refreshed: Date?
    var totalConvertedCount: Int64? = 0
    
    init(
        blocklistId: UUID? = nil,
        compiledSuccessfully: Bool? = nil,
        errorsCount: Int64? = nil,
        httpCode: Int16? = nil,
        id: UUID? = nil,
        overLimit: Bool? = nil,
        refreshed: Date? = nil,
        totalConvertedCount: Int64? = nil
    ) {
        self.blocklistId = blocklistId
        self.compiledSuccessfully = compiledSuccessfully
        self.errorsCount = errorsCount
        self.httpCode = httpCode
        self.id = id
        self.overLimit = overLimit
        self.refreshed = refreshed
        self.totalConvertedCount = totalConvertedCount
    }
    
    static func create(
        in modelContext: ModelContext,
        blocklist: Blocklist
    ) -> BlocklistStatus {
        let blocklistStatus = BlocklistStatus()
        blocklistStatus.id = UUID()
        blocklistStatus.blocklistId = blocklist.id
        
        modelContext.insert(blocklistStatus)

        return blocklistStatus
    }
}
