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
    static var defaultSource = SourceDetail(
        id: "inbox",
        entityType: nil,
        title: "Inbox",
        symbol: "tray"
    )
    
    func entities(for identifiers: [SourceDetail.ID]) async throws -> [SourceDetail] {
        do {
            let all = try await suggestedEntities()
            
            return all.filter { identifiers.contains($0.id) }
        } catch {
            print("Could not load widget entities")
            
            return []
        }
    }
    
    func suggestedEntities() async throws -> [SourceDetail] {
        var sources = [SourceQuery.defaultSource]
        
        await PersistenceController.shared.container.performBackgroundTask { context in
            let request = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(keyPath: \Page.userOrder, ascending: true)]
            
            if let pages = try? context.fetch(request) {
                for page in pages {
                    guard let pageID = page.id else { continue }
                    sources.append(SourceDetail(
                        id: pageID.uuidString,
                        entityType: Page.self,
                        title: page.wrappedName,
                        symbol: page.wrappedSymbol
                    ))
                    
                    for feed in page.feedsArray {
                        guard let feedID = feed.id else { continue }
                        sources.append(SourceDetail(
                            id: feedID.uuidString,
                            entityType: Feed.self,
                            title: feed.wrappedTitle,
                            symbol: nil
                        ))
                    }
                }
            }
        }
        
        return sources
    }
    
    func defaultResult() async -> SourceDetail? {
        try? await suggestedEntities().first
    }
}
