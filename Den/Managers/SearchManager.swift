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

class SearchManager: ObservableObject {
    @Published var query: String = ""
    @Published var results: [[Item]] = []
    @Published var isEditing: Bool = false

    private var managedObjectContext: NSManagedObjectContext
    private var cancellable: AnyCancellable? = nil

    init(moc managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        
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
    
    private func searchIsValid(query: String) -> Bool {
        if query == "" || query.count >= 3 {
            return true
        }
        return false
    }
    
    private func performSearch(query: String) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        fetchRequest.predicate = NSPredicate(
            format: "%K CONTAINS[C] %@ OR %K CONTAINS[C] %@",
            #keyPath(Item.title),
            query,
            #keyPath(Item.feed.title),
            query
        )
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \Item.published, ascending: false)]
    
        do {
            let fetchResults = try managedObjectContext.fetch(fetchRequest) as! [Item]
            self.results = groupFetchResults(fetchResults)
        } catch {
            fatalError("Failed to execute search: \(error)")
        }
    }
    
    private func groupFetchResults(_ fetchResults: [Item])-> [[Item]] {
        Dictionary(grouping: fetchResults) { item in
            item.feed!
        }.values.sorted { a, b in
            return a[0].feed!.title! < b[0].feed!.title!
        }
    }
}
