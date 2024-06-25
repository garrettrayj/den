//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 1/3/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct SearchView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Binding var searchQuery: String
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    @Query(sort: [
        SortDescriptor(\Search.submitted, order: .reverse)
    ])
    private var searches: [Search]
    
    var body: some View {
        Group {
            if searchQuery == "" {
                ContentUnavailable {
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
                .navigationTitle(Text("Search", comment: "Navigation title."))
            } else {
                WithItems(
                    includeExtras: true,
                    searchQuery: searchQuery
                ) { items in
                    SearchLayout(
                        hideRead: $hideRead,
                        query: searchQuery,
                        items: items
                    )
                    .navigationTitle(
                        Text("Search", comment: "Navigation title.")
                    )
                    .toolbar {
                        SearchToolbar(hideRead: $hideRead, query: searchQuery, items: items)
                    }
                }
            }
        }
        .onAppear { saveSearch() }
        .onChange(of: searchQuery) { saveSearch() }
    }
    
    private func saveSearch() {
        guard searchQuery != "" else { return }

        if let search = searches.first(where: {
            $0.query?.lowercased() == searchQuery.lowercased()
        }) {
            search.query = searchQuery
            search.submitted = Date()
        } else {
            _ = Search.create(in: modelContext, query: searchQuery)
        }
    }
}
