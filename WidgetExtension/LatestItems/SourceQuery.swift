//
//  SourceQuery.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/1/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import AppIntents
import Foundation
import SwiftData

struct SourceQuery: EntityQuery {
    static let defaultSource = SourceDetail(
        id: UUID(),
        entityType: nil,
        title: "Inbox",
        symbol: "tray"
    )
    
    func entities(for identifiers: [SourceDetail.ID]) async throws -> [SourceDetail] {
        let all = try await suggestedEntities()
        return all.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [SourceDetail] {
        var sources = [SourceQuery.defaultSource]
        
        let context = ModelContext(DataController.shared.container)
        
        var request = FetchDescriptor<Page>()
        request.sortBy = [SortDescriptor(\Page.userOrder)]
        
        for page in try context.fetch(request) {
            guard let pageID = page.id else { continue }
            sources.append(SourceDetail(
                id: pageID,
                entityType: Page.self,
                title: page.wrappedName,
                symbol: page.wrappedSymbol
            ))
            
            for feed in page.sortedFeeds {
                guard let feedID = feed.id else { continue }
                sources.append(SourceDetail(
                    id: feedID,
                    entityType: Feed.self,
                    title: feed.wrappedTitle,
                    symbol: nil
                ))
            }
        }
        
        return sources
    }
    
    func defaultResult() async -> SourceDetail? {
        try? await suggestedEntities().first
    }
}
