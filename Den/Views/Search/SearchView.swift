//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 1/3/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct SearchView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile
    
    @Binding var hideRead: Bool
    @Binding var searchQuery: String
    
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
                    scopeObject: profile,
                    includeExtras: true,
                    searchQuery: searchQuery
                ) { items in
                    SearchLayout(
                        profile: profile,
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
