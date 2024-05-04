//
//  SourceQuery.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation
import AppIntents

struct SourceQuery: EntityQuery {
    func entities(for identifiers: [SourceDetail.ID]) async throws -> [SourceDetail] {
        SourceDetail.allSources.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [SourceDetail] {
        SourceDetail.allSources
    }
    
    func defaultResult() async -> SourceDetail? {
        try? await suggestedEntities().first
    }
}
