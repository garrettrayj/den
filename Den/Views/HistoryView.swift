//
//  HistoryView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI
import CoreData
import Grid
import OSLog
import Combine

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var linkManager: LinkManager
    @EnvironmentObject var crashManager: CrashManager

    @State private var searchQuery: String = ""
    @State private var searchResults: [[History]] = []

    private var dateFormatter = DateFormatter.create(dateStyle: .medium, timeStyle: .none)

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView(searchQuery: $searchQuery)

                if searchResults.count == 0 && searchQuery == "" {
                    Text("History empty or unavailable")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()
                } else if searchResults.count == 0 && searchQuery != "" {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .padding()

                } else {
                    List {
                        ForEach(searchResults, id: \.self) { resultGroup in
                            if resultGroup.first?.visited != nil {
                                Section(
                                    header: Text("\(resultGroup.first!.visited!, formatter: dateFormatter)")
                                ) {
                                    ForEach(resultGroup) { result in
                                        if result.title != nil && result.link != nil {
                                            Button { linkManager.openLink(url: result.link!) } label: {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(result.title!).font(.system(size: 18))
                                                    Text(result.link!.absoluteString)
                                                        .font(.caption)
                                                        .foregroundColor(Color.secondary)
                                                        .lineLimit(1)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.search(query: searchQuery)
        }
        .onReceive(
            searchQuery
                .publisher
                .removeDuplicates()
                .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
                .collect(),
            perform: { _ in
                DispatchQueue.main.async {
                    let trimmedQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
                    self.search(query: trimmedQuery)
                }
            }
        )

    }

    private func search(query: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.visited, ascending: false)]

        if query != "" {
            fetchRequest.predicate = NSPredicate(
                format: "%K CONTAINS[C] %@",
                #keyPath(History.title),
                query
            )
        }

        do {
            guard let fetchResults = try viewContext.fetch(fetchRequest) as? [History] else { return }
            var compactedFetchResults: [History] = []
            fetchResults.forEach { history in
                if history.visited != nil {
                    compactedFetchResults.append(history)
                }
            }

            let grouping = Dictionary(
                grouping: compactedFetchResults,
                by: { DateFormatter.getFormattedDate(date: $0.visited!, format: "yyyy-MM-dd") }
            )

            self.searchResults = grouping.values.sorted { aHistory, bHistory in
                return aHistory[0].visited! > bHistory[0].visited!
            }
        } catch {
            Logger.main.error("Failed to fetch search results: \(error as NSError)")
        }
    }
}
