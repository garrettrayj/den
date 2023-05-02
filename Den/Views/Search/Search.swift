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

    @Binding var hideRead: Bool

    var query: String

    var body: some View {
        if query == "" {
            SplashNote(
                title: "Searching \(profile.wrappedName)",
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
                    hideRead: hideRead,
                    query: query,
                    items: items.visibilityFiltered(hideRead ? false : nil)
                )
                .toolbar {
                    SearchBottomBar(profile: profile, hideRead: $hideRead, query: query, items: items)
                }
                .navigationTitle("Search")
            }
        }
    }
}
