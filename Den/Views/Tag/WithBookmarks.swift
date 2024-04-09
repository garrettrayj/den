//
//  WithBookmarks.swift
//  Den
//
//  Created by Garrett Johnson on 2/19/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct WithBookmarks<Content: View>: View {
    @ViewBuilder let content: (FetchedResults<Bookmark>) -> Content

    @FetchRequest(sortDescriptors: [])
    private var bookmarks: FetchedResults<Bookmark>

    var body: some View {
        content(bookmarks)
    }

    init(
        scopeObject: NSManagedObject? = nil,
        sortDescriptors: [NSSortDescriptor] = [
            NSSortDescriptor(keyPath: \Bookmark.created, ascending: false)
        ],
        readFilter: Bool? = nil,
        searchQuery: String = "",
        @ViewBuilder content: @escaping (FetchedResults<Bookmark>) -> Content
    ) {
        self.content = content

        var predicates: [NSPredicate] = []

        if let tag = scopeObject as? Tag {
            predicates.append(NSPredicate(format: "tag = %@", tag))
        }

        if readFilter != nil {
            predicates.append(NSPredicate(format: "read = %@", NSNumber(value: readFilter!)))
        }

        if !searchQuery.isEmpty {
            predicates.append(NSPredicate(
                format: "title CONTAINS[c] %@",
                "\(searchQuery)"
            ))
        }

        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: predicates)
        let request: NSFetchRequest<Bookmark> = Bookmark.fetchRequest()
        request.predicate = compoundPredicate
        request.sortDescriptors = sortDescriptors

        _bookmarks = FetchRequest(fetchRequest: request)
    }
}
