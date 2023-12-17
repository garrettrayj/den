//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 4/12/23.
//  Copyright © 2023 Garrett Johnson
//

import CoreData
import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @SceneStorage("SearchQuery") private var searchQuery = ""
    @SceneStorage("SearchInput") private var searchInput = ""

    @AppStorage("SearchHideRead") private var hideRead = false

    var body: some View {
        ZStack {
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
                    scopeObject: profile,
                    includeExtras: true,
                    searchQuery: searchQuery
                ) { items in
                    SearchLayout(
                        hideRead: $hideRead,
                        query: searchQuery,
                        items: items
                    )
                    .navigationTitle(
                        Text("Search")
                    )
                    .toolbar {
                        SearchToolbar(hideRead: $hideRead, query: searchQuery, items: items)
                    }
                }
            }
        }
        .onAppear { saveSearch() }
        .onChange(of: searchQuery) { saveSearch() }
        #if os(macOS)
        .searchable(
            text: $searchInput,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        #else
        .searchable(
            text: $searchInput,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        #endif
        .searchSuggestions {
            ForEach(profile.searchesArray.prefix(20)) { search in
                if search.wrappedQuery != "" {
                    Text(verbatim: search.wrappedQuery).searchCompletion(search.wrappedQuery)
                }
            }
        }
        .onSubmit(of: .search) {
            searchQuery = searchInput
        }
    }

    private func saveSearch() {
        guard searchQuery != "" else { return }

        if let search = profile.searchesArray.first(where: {
            $0.query?.lowercased() == searchQuery.lowercased()
        }) {
            search.query = searchQuery
            search.submitted = Date()
        } else {
            _ = Search.create(in: viewContext, profile: profile, query: searchQuery)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
