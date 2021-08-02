//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

import Grid

struct SearchView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView()

                if searchManager.searchResults.count > 0 && searchManager.searchIsValid() {
                    ScrollView {
                        Grid(searchManager.searchResults, id: \.self) { sectionItems in
                            SearchResultView(items: sectionItems)
                        }
                        .gridStyle(StaggeredGridStyle(.vertical, tracks: Tracks.min(300), spacing: 16))
                        .padding()
                        .padding(.bottom, 64)
                    }
                } else if searchManager.searchQuery == "" {
                    Text("Filter Current Headlines by Keyword").modifier(SimpleMessageModifier())
                } else if !searchManager.searchIsValid() {
                    Text("Minimum Three Characters Required to Search").modifier(SimpleMessageModifier())
                } else {
                    Text("No Results Found").modifier(SimpleMessageModifier())
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(
                searchManager.searchQuery
                    .publisher
                    .removeDuplicates()
                    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                    .collect(),
                perform: { _ in
                    DispatchQueue.main.async {
                        searchManager.trimQuery()
                        if searchManager.searchIsValid() {
                            self.search(query: searchManager.searchQuery)
                        }
                    }

                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }

    private func search(query: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[C] %@",
            #keyPath(Item.title),
            query
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
        fetchRequest.relationshipKeyPathsForPrefetching = ["feed"]

        do {
            guard let fetchResults = try viewContext.fetch(fetchRequest) as? [Item] else { return }
            var compactedFetchResults: [Item] = []
            fetchResults.forEach { item in
                if item.feedData?.feed != nil {
                    compactedFetchResults.append(item)
                }
            }

            searchManager.searchResults = Dictionary(grouping: compactedFetchResults) { item in
                item.feedData!
            }.values.sorted { aItem, bItem in
                guard
                    let aTitle = aItem[0].feedData?.feed?.wrappedTitle,
                    let bTitle = bItem[0].feedData?.feed?.wrappedTitle
                else {
                    return false
                }

                return aTitle < bTitle
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
