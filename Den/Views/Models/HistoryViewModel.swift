//
//  HistoryViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

final class HistoryViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var results: [[History]] = []
    @Published var queryIsValid: Bool?
    @Published var validationMessage: String?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager

        self.performHistorySearch()
    }

    func reset() {
        query = ""
        performHistorySearch()
    }

    func validateQuery() -> Bool {
        queryIsValid = true

        if query != "" && query.count < 3 {
            queryIsValid = false
            validationMessage = "Search needs at least three characters"
        }

        return queryIsValid!
    }

    func performHistorySearch() {
        if validateQuery() == false {
            return
        }

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
                by: { DateFormatter.longNone.string(from: $0.visited!) }
            )

            results = grouping.values.sorted { aHistory, bHistory in
                return aHistory[0].visited! > bHistory[0].visited!
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
