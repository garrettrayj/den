//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct SearchView: View {
    @ObservedObject var profile: Profile
    @ObservedObject var search: Search

    @Binding var hideRead: Bool

    var body: some View {
        ZStack {
            if search.query == "" {
                ContentUnavailableView {
                    Label {
                        Text("No Query", comment: "Search query empty title.")
                    } icon: {
                        Image(systemName: "magnifyingglass")
                    }
                } description: {
                    Text(
                        "Enter a term to search item titles.",
                        comment: "Search query empty guidance."
                    )
                }
            } else {
                WithItems(
                    scopeObject: profile,
                    includeExtras: true,
                    searchQuery: search.wrappedQuery
                ) { items in
                    SearchLayout(
                        profile: profile,
                        search: search,
                        hideRead: $hideRead,
                        items: items
                    )
                    .toolbar {
                        SearchToolbar(hideRead: $hideRead, query: search.wrappedQuery, items: items)
                    }
                }
            }
        }
        .navigationTitle(Text("Search", comment: "Navigation title."))
    }
}
