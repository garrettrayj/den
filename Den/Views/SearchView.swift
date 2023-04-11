//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchView: View {
    @FetchRequest(sortDescriptors: [])
    private var searchResults: FetchedResults<Item>

    @ObservedObject var profile: Profile

    var query: String

    init(profile: Profile, query: String) {
        self.query = query

        _profile = ObservedObject(wrappedValue: profile)

        let trimmedQuery = query.trimmingCharacters(in: .whitespaces)

        let profilePredicate = NSPredicate(
            format: "feedData.id IN %@",
            profile.pagesArray.flatMap({ page in
                page.feedsArray.compactMap { feed in
                    feed.feedData?.id
                }
            })
        )
        let queryPredicate = NSPredicate(
            format: "title CONTAINS[c] %@",
            trimmedQuery.count > 0 ? "\(trimmedQuery)" : ""
        )
        let compoundPredicate = NSCompoundPredicate(
            type: .and,
            subpredicates: [profilePredicate, queryPredicate]
        )

        _searchResults = FetchRequest<Item>(
            entity: Item.entity(),
            sortDescriptors: [
                NSSortDescriptor(keyPath: \Item.published, ascending: false)
            ],
            predicate: compoundPredicate
        )
    }

    var body: some View {
        GeometryReader { geometry in
            if query == "" {
                SplashNote(
                    title: "Searching \(profile.wrappedName)",
                    symbol: "magnifyingglass"
                )
            } else if searchResults.isEmpty {
                SplashNote(title: "No items found for “\(query)”")
            } else {
                ScrollView(.vertical) {
                    BoardView(geometry: geometry, list: Array(searchResults)) { item in
                        FeedItemExpanded(item: item, profile: profile)
                    }.modifier(MainBoardModifier())
                }.edgesIgnoringSafeArea(.horizontal)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle("Search")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Text(statusString).font(.caption)
            }
        }
    }

    private var statusString: String {
        if query.isEmpty {
            return "Enter a word or phrase to look for in item titles."
        } else {
            return "Results for “\(query)”"
        }
    }
}
