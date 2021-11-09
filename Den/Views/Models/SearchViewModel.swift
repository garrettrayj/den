//
//  SearchViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/22/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import Combine

final class SearchViewModel: ObservableObject {
    @Published var searchText: String = ""
    @Published var results: [[Item]] = []
    @Published var queryIsValid: Bool?
    @Published var validationMessage: String?

    private var viewContext: NSManagedObjectContext

    public var contentViewModel: ContentViewModel

    init(viewContext: NSManagedObjectContext, contentViewModel: ContentViewModel) {
        self.viewContext = viewContext
        self.contentViewModel = contentViewModel
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

            results = Dictionary(grouping: compactedFetchResults) { item in
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
            contentViewModel.handleCriticalError(error as NSError)
        }
    }
}
