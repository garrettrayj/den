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

    @Binding var hideRead: Bool

    let query: String

    var body: some View {
        Group {
            if query == "" {
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
                    searchQuery: query
                ) { items in
                    SearchLayout(
                        profile: profile,
                        hideRead: $hideRead,
                        query: query,
                        items: items
                    )
                    .navigationTitle(
                        Text("Search")
                    )
                    .toolbar {
                        SearchToolbar(hideRead: $hideRead, query: query, items: items)
                    }
                }
            }
        }
        .onAppear { saveSearch() }
        .onChange(of: query) { saveSearch() }
    }

    private func saveSearch() {
        guard query != "" else { return }

        if let search = profile.searchesArray.first(where: {
            $0.query?.lowercased() == query.lowercased()
        }) {
            search.query = query
            search.submitted = Date()
        } else {
            _ = Search.create(in: viewContext, profile: profile, query: query)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
