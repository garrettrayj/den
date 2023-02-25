//
//  WithItemsView.swift
//  Den
//
//  Created by Garrett Johnson on 2/25/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct WithItemsView<Content: View, ScopeObject: ObservableObject>: View {
    let content: (ScopeObject, FetchedResults<Item>) -> Content

    @ObservedObject private var scopeObject: ScopeObject

    @FetchRequest(sortDescriptors: [SortDescriptor(\.published, order: .reverse)])
    private var items: FetchedResults<Item>

    var body: some View {
        content(scopeObject, items)
    }

    init(
        scopeObject: ScopeObject,
        excludingRead: Bool,
        @ViewBuilder content: @escaping (ScopeObject, FetchedResults<Item>) -> Content
    ) {
        _scopeObject = ObservedObject(wrappedValue: scopeObject)

        self.content = content

        var predicates: [NSPredicate] = []

        if let feed = scopeObject as? Feed {
            predicates.append(NSPredicate(format: "feedData.id = %@", feed.feedData!.id!.uuidString))
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
        }

        if excludingRead {
            predicates.append(NSPredicate(format: "read = false"))
        }

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let request: NSFetchRequest<Item> = Item.fetchRequest()
        request.predicate = compoundPredicate
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]

        _items = FetchRequest(fetchRequest: request)
    }
}
