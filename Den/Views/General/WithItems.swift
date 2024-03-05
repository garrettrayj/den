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

struct WithItems<Content: View>: View {
    @ViewBuilder let content: (FetchedResults<Item>) -> Content

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    var body: some View {
        content(items)
    }

    init(
        scopeObject: NSManagedObject,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \Item.published, ascending: false)
        ],
        readFilter: Bool? = nil,
        includeExtras: Bool = false,
        searchQuery: String = "",
        @ViewBuilder content: @escaping (FetchedResults<Item>) -> Content
    ) {
        self.content = content

        var predicates: [NSPredicate] = []

        if let feed = scopeObject as? Feed {
            if let feedData = feed.feedData {
                predicates.append(NSPredicate(format: "feedData = %@", feedData))
            } else {
                // Impossible query because there should be no items without FeedData
                predicates.append(NSPredicate(format: "1 = 2"))
            }
        } else if let page = scopeObject as? Page {
            predicates.append(NSPredicate(
                format: "feedData IN %@",
                page.feedsArray.compactMap { $0.feedData }
            ))
        } else if let profile = scopeObject as? Profile {
            predicates.append(NSPredicate(
                format: "feedData IN %@",
                profile.feedsArray.compactMap { $0.feedData }
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
