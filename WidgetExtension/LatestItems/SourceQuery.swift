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
    static let defaultSource = SourceDetail(
        id: "inbox",
        entityType: nil,
        title: "Inbox",
        symbol: nil
    )
    
    func entities(for identifiers: [SourceDetail.ID]) async throws -> [SourceDetail] {
        let all = try await suggestedEntities()
        return all.filter { identifiers.contains($0.id) }
    }
    
    func suggestedEntities() async throws -> [SourceDetail] {
        var sources = [SourceQuery.defaultSource]

        let context = WidgetDataController.getContainer().newBackgroundContext()

        try context.performAndWait {
            let request = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
            
            for page in try context.fetch(request) {
                guard let pageID = page.id else { continue }
                sources.append(SourceDetail(
                    id: pageID.uuidString,
                    entityType: Page.self,
                    title: .init(stringLiteral: page.wrappedName),
                    symbol: page.wrappedSymbol
                ))
                
                for feed in page.feedsArray {
                    guard let feedID = feed.id else { continue }
                    sources.append(SourceDetail(
                        id: feedID.uuidString,
                        entityType: Feed.self,
                        title: .init(stringLiteral: page.wrappedName),
                        symbol: nil
                    ))
                }
            }
        }
        
        return sources
    }
    
    func defaultResult() async -> SourceDetail? {
        try? await suggestedEntities().first
    }
}
