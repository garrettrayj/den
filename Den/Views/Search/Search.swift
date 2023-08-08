//
//  Search.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

struct Search: View {
    @ObservedObject var profile: Profile

    let query: String

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        ZStack {
            if query == "" {
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
                    searchQuery: query
                ) { items in
                    SearchLayout(
                        profile: profile,
                        hideRead: $hideRead,
                        query: query,
                        items: items
                    )
                    .toolbar(id: "Search") {
                        SearchToolbar(hideRead: $hideRead, query: query, items: items)
                    }
                    .navigationTitle(Text("Search", comment: "Navigation title."))
                }
            }
        }
    }
}
