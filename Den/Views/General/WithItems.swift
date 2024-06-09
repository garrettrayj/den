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
        
        if let feed = scopeObject as? Feed {
            if let feedDataID = feed.feedData?.persistentModelID {
                let feedScopePredicate = #Predicate<Item> { $0.feedData?.persistentModelID == feedDataID }
                predicates.append(feedScopePredicate)
            }
        } else if let page = scopeObject as? Page {
            var pagePredicates: [Predicate<Item>] = []
            let feedDataIDs = page.feedsArray.compactMap { $0.feedData?.persistentModelID }
            
            if feedDataIDs.isEmpty {
                let fakeUUID = UUID()
                let emptyPredicate = #Predicate<Item> { $0.id == fakeUUID }
                predicates.append(emptyPredicate)
            } else {
                for feedDataID in feedDataIDs {
                    let pagePredicate = #Predicate<Item> { $0.feedData?.persistentModelID == feedDataID }
                    pagePredicates.append(pagePredicate)
                }
                let pagePredicate = pagePredicates.disjunction()
                predicates.append(pagePredicate)
            }
        }

        if readFilter != nil {
            let readPredicate = #Predicate<Item> { $0.wrappedRead == readFilter! }
            predicates.append(readPredicate)
        }

        if !includeExtras {
            let extrasPredicate = #Predicate<Item> { $0.extra == false }
            predicates.append(extrasPredicate)
        }

        if !searchQuery.isEmpty {
            let searchPredicate = #Predicate<Item> { $0.title?.contains(searchQuery) ?? false }
            predicates.append(searchPredicate)
        }

        request.predicate = predicates.conjunction()

        _items = Query(request)
    }
}
