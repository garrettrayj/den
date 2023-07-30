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
        if query == "" {
            SplashNote(
                Text("No Query", comment: "Search query empty title."),
                caption: {
                    Text(
                        "Enter a term to search for in item titles.",
                        comment: "Search query empty guidance."
                    )
                }
            )
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
