//
//  SearchManager.swift
//  Den
//
//  Created by Garrett Johnson on 9/7/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import Combine
import SwiftUI
import CoreData
import OSLog

class SearchManager: ObservableObject {
    @Published var query: String = ""
    @Published var results: [[Item]] = []
    @Published var isEditing: Bool = false

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    
    private var cancellable: AnyCancellable? = nil

    init(persistenceManager: PersistenceManager, crashManager: CrashManager) {
        self.viewContext = persistenceManager.container.viewContext
        self.crashManager = crashManager
        
        cancellable = AnyCancellable(
            $query
                .removeDuplicates()
                .debounce(for: 0.6, scheduler: DispatchQueue.main)
                .sink { searchText in
                    let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
                    if self.searchIsValid(query: trimmedQuery) {
                        self.performSearch(query: trimmedQuery)
                    }
                }
        )
    }
    
    deinit {
        cancellable?.cancel()
    }
    
    func searchIsValid(query: String) -> Bool {
        if query == "" || query.count >= 3 {
            return true
        }
        return false
    }
    
    private func performSearch(query: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[C] %@",
            #keyPath(Item.title),
            query
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
    
        do {
            let fetchResults = try viewContext.fetch(fetchRequest) as! [Item]
            self.results = groupFetchResults(fetchResults)
        } catch let error as NSError {
            Logger.main.error("Unable to execute search: \(error)")
        }
    }
    
    private func groupFetchResults(_ fetchResults: [Item])-> [[Item]] {
        Dictionary(grouping: fetchResults) { item in
            item.feed!
        }.values.sorted { a, b in
            return a[0].feed!.subscription!.title! < b[0].feed!.subscription!.title!
        }
    }
}
