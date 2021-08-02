//
//  SearchManager.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class SearchManager: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [[Item]] = []
    @Published var historyResults: [[History]] = []

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func reset() {
        searchQuery = ""
    }

    func searchIsValid() -> Bool {
        if searchQuery.count >= 3 {
            return true
        }

        return false
    }

    func performItemSearch() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[C] %@",
            #keyPath(Item.title),
            searchQuery
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

            searchResults = Dictionary(grouping: compactedFetchResults) { item in
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

    func performHistorySearch() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \History.visited, ascending: false)]

        if searchQuery != "" {
            fetchRequest.predicate = NSPredicate(
                format: "%K CONTAINS[C] %@",
                #keyPath(History.title),
                searchQuery
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

            historyResults = grouping.values.sorted { aHistory, bHistory in
                return aHistory[0].visited! > bHistory[0].visited!
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
