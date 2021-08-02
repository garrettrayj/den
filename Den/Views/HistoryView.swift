//
//  HistoryView.swift
//  Den
//
//  Created by Garrett Johnson on 5/21/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct HistoryView: View {
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var linkManager: LinkManager
    @EnvironmentObject var crashManager: CrashManager
    @EnvironmentObject var searchManager: SearchManager

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                SearchFieldView()

                if searchManager.historyResults.count == 0 && searchManager.searchQuery == "" {
                    Text("History is Empty").modifier(SimpleMessageModifier())
                } else if !searchManager.searchIsValid() {
                    Text("Minimum Three Characters Required to Search").modifier(SimpleMessageModifier())
                } else if searchManager.historyResults.count == 0 && searchManager.searchQuery != "" {
                    Text("No Results Found").modifier(SimpleMessageModifier())
                } else {
                    resultsList
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color(UIColor.secondarySystemBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("History")
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            self.search(query: searchManager.searchQuery)
        }
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

    private var resultsList: some View {
        List {
            ForEach(searchManager.historyResults, id: \.self) { resultGroup in
                if resultGroup.first?.visited != nil {
                    Section(
                        header: Text("\(resultGroup.first!.visited!, formatter: DateFormatter.mediumNone)")
                    ) {
                        ForEach(resultGroup) { result in
                            if result.title != nil && result.link != nil {
                                Button { linkManager.openLink(url: result.link!) } label: {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(result.title!).font(.title3)
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
                by: { DateFormatter.isoDate.string(from: $0.visited!) }
            )

            searchManager.historyResults = grouping.values.sorted { aHistory, bHistory in
                return aHistory[0].visited! > bHistory[0].visited!
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
