//
//  WithItems.swift
//  Den
//
//  Created by Garrett Johnson on 2/25/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

import CompoundPredicate

struct WithItems<Content: View>: View {
    @ViewBuilder let content: ([Item]) -> Content

    @Query()
    private var items: [Item]

    var body: some View {
        content(items)
    }

    init(
        scopeObject: (any PersistentModel)? = nil,
        sortDescriptors: [SortDescriptor<Item>] = [
            SortDescriptor(\Item.published, order: .reverse)
        ],
        readFilter: Bool? = nil,
        includeExtras: Bool = false,
        searchQuery: String = "",
        @ViewBuilder content: @escaping ([Item]) -> Content
    ) {
        self.content = content

        var request = FetchDescriptor<Item>()
        request.sortBy = sortDescriptors
        
        var predicates: [Predicate<Item>] = []
        
        if let readFilter {
            let readPredicate = #Predicate<Item> { $0.read == readFilter }
            predicates.append(readPredicate)
        }

        if !includeExtras {
            let extrasPredicate = #Predicate<Item> { $0.extra == false }
            predicates.append(extrasPredicate)
        }
        
        if let feed = scopeObject as? Feed {
            var feedDataIDs: [PersistentIdentifier] = []
            if let feedDataID = feed.feedData?.persistentModelID {
                feedDataIDs.append(feedDataID)
            }
            let feedScopePredicate = #Predicate<Item> { item in
                if let feedData = item.feedData {
                    return feedDataIDs.contains(feedData.persistentModelID)
                } else {
                    return false
                }
            }
            predicates.append(feedScopePredicate)
        } else if let page = scopeObject as? Page {
            let feedDataIDs = page.wrappedFeeds.compactMap { $0.feedData?.persistentModelID }
            let pageScopePredicate = #Predicate<Item> { item in
                if let feedData = item.feedData {
                    return feedDataIDs.contains(feedData.persistentModelID)
                } else {
                    return false
                }
            }
            predicates.append(pageScopePredicate)
        }

        if !searchQuery.isEmpty {
            let searchPredicate = #Predicate<Item> {
                $0.title?.localizedStandardContains(searchQuery) ?? false
            }
            predicates.append(searchPredicate)
        }

        request.predicate = predicates.conjunction()

        _items = Query(request)
    }
}
