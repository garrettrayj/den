//
//  WithItems.swift
//  Den
//
//  Created by Garrett Johnson on 2/25/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct WithItems<Content: View, ScopeObject: ObservableObject>: View {
    let content: (FetchedResults<Item>) -> Content

    @ObservedObject var scopeObject: ScopeObject

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    var body: some View {
        content(items)
    }

    init(
        scopeObject: ScopeObject,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \Item.published, ascending: false)
        ],
        readFilter: Bool? = nil,
        includeExtras: Bool = false,
        searchQuery: String = "",
        @ViewBuilder content: @escaping (FetchedResults<Item>) -> Content
    ) {
        self.content = content
        self.scopeObject = scopeObject

        var predicates: [NSPredicate] = []

        if let feed = scopeObject as? Feed {
            if let feedData = feed.feedData {
                predicates.append(NSPredicate(format: "feedData = %@", feedData))
            } else {
                // Impossible query because there will be no items without FeedData
                predicates.append(NSPredicate(format: "1 = 2"))
            }
        } else if let page = scopeObject as? Page {
            predicates.append(NSPredicate(
                format: "feedData IN %@",
                page.feedsArray.compactMap { feed in
                    feed.feedData
                }
            ))
        } else if let profile = scopeObject as? Profile {
            predicates.append(NSPredicate(
                format: "feedData IN %@",
                profile.feedsArray.compactMap { feed in
                    feed.feedData
                }
            ))
        } else if let trend = scopeObject as? Trend {
            predicates.append(NSPredicate(
                format: "id IN %@",
                trend.items.map { $0.id }
            ))
        }

        if readFilter != nil {
            predicates.append(NSPredicate(format: "read = %@", NSNumber(value: readFilter!)))
        }

        if !includeExtras {
            predicates.append(NSPredicate(format: "extra = %@", NSNumber(value: false)))
        }

        if !searchQuery.isEmpty {
            predicates.append(NSPredicate(
                format: "title CONTAINS[c] %@",
                "\(searchQuery)"
            ))
        }

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = compoundPredicate
        request.sortDescriptors = sortDescriptors

        _items = FetchRequest(fetchRequest: request)
    }
}
