//
//  SearchViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import Combine

class SearchResultGroup: Identifiable, Equatable, Hashable {
    var id: UUID
    var items: [Item]

    init(id: UUID, items: [Item]) {
        self.id = id
        self.items = items
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: SearchResultGroup, rhs: SearchResultGroup) -> Bool {
        return lhs.id == rhs.id
    }
}

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [SearchResultGroup] = []
    @Published var queryIsValid: Bool?
    @Published var validationMessage: String?

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func reset() {
        searchText = ""
        results = []
        queryIsValid = nil
    }

    func validateQuery() -> Bool {
        queryIsValid = true

        if searchText == "" {
            queryIsValid = false
            validationMessage = "Search is empty"
        }

        if searchText.count < 3 {
            queryIsValid = false
            validationMessage = "Search needs at least three characters"
        }

        return queryIsValid!
    }

    func performItemSearch() {
        if validateQuery() == false {
            return
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[C] %@",
            #keyPath(Item.title),
            searchText
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

            let groupedResults = Dictionary(grouping: compactedFetchResults) { item in
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

            groupedResults.forEach { items in
                guard let id = items.first?.feedData?.feed?.id else { return }

                results.append(SearchResultGroup(id: id, items: items))
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
