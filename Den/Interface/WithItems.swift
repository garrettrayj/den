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
    let content: (ScopeObject, FetchedResults<Item>) -> Content

    @ObservedObject private var scopeObject: ScopeObject

    @FetchRequest(sortDescriptors: [])
    private var items: FetchedResults<Item>

    @ViewBuilder
    var body: some View {
        content(scopeObject, items)
    }

    init(
        scopeObject: ScopeObject,
        sortDescriptors: [NSSortDescriptor] = [],
        readFilter: Bool? = nil,
        @ViewBuilder content: @escaping (ScopeObject, FetchedResults<Item>) -> Content
    ) {
        _scopeObject = ObservedObject(wrappedValue: scopeObject)

        self.content = content

        var predicates: [NSPredicate] = []

        if let feed = scopeObject as? Feed {
            guard let feedDataID = feed.feedData?.id?.uuidString else { return }
            predicates.append(NSPredicate(format: "feedData.id = %@", feedDataID))
        } else if let page = scopeObject as? Page {
            predicates.append(NSPredicate(
                format: "feedData.id IN %@",
                page.feedsArray.compactMap { feed in
                    feed.feedData?.id
                }
            ))
        } else if let profile = scopeObject as? Profile {
            predicates.append(NSPredicate(
                format: "feedData.id IN %@",
                profile.pagesArray.flatMap({ page in
                    page.feedsArray.compactMap { feed in
                        feed.feedData?.id
                    }
                })
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

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = compoundPredicate
        request.sortDescriptors = sortDescriptors

        _items = FetchRequest(fetchRequest: request)
    }
}
