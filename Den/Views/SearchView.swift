//
//  SearchView.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData
import Grid
import OSLog

struct SearchView: View {
    @Environment(\.managedObjectContext) var viewContext
    
    @State private var searchQuery: String = ""
    @State private var searchResults: [[Item]] = []
    
    var body: some View {
        NavigationView() {
            VStack(spacing: 0) {
                SearchFieldView(searchQuery: $searchQuery)
                
                if searchResults.count > 0 && searchIsValid(query: searchQuery) {
                    ScrollView {
                        Grid(searchResults, id: \.self) { sectionItems in
                            SearchResultView(items: sectionItems)
                        }
                        .gridStyle(StaggeredGridStyle(availableWidth: 200))
                        .padding()
                        .padding(.bottom, 64)
                    }
                } else if searchQuery == "" {
                    Text("Filter current headlines by keyword")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                } else if !searchIsValid(query: searchQuery) {
                    Text("Minimum three characters required")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                } else {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .onReceive(
                searchQuery
                    .publisher
                    .removeDuplicates()
                    .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                    .collect(),
                perform: { _ in
                    DispatchQueue.main.async {
                        let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                        if self.searchIsValid(query: trimmedQuery) {
                            self.search(query: trimmedQuery)
                        }
                    }
                    
                }
            )
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private func searchIsValid(query: String) -> Bool {
        if query == "" || query.count >= 3 {
            return true
        }
        return false
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
            let fetchResults = try viewContext.fetch(fetchRequest) as! [Item]
            var compactedFetchResults: [Item] = []
            fetchResults.forEach { item in
                if item.feedData?.feed != nil {
                    compactedFetchResults.append(item)
                }
            }
            
            self.searchResults = Dictionary(grouping: compactedFetchResults) { item in
                item.feedData!
            }.values.sorted { a, b in
                guard
                    let aTitle = a[0].feedData?.feed?.wrappedTitle,
                    let bTitle = b[0].feedData?.feed?.wrappedTitle
                else {
                    return false
                }
                
                return aTitle < bTitle
            }
        } catch {
            Logger.main.error("Failed to fetch search results: \(error as NSError)")
        }
    }
}
