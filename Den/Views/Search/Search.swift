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

    @Binding var query: String
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        if query == "" {
            SplashNote(
                title: Text("Searching \(profile.wrappedName)", comment: "Empty search query message."),
                symbol: "magnifyingglass"
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
                    query: $query,
                    items: items
                )
                .toolbar {
                    SearchToolbar(profile: profile, hideRead: $hideRead, query: $query, items: items)
                }
                .navigationTitle(Text("Search", comment: "Navigation title."))
            }
        }
    }
}
