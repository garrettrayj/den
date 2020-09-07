//
//  SearchViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 9/6/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var isEditing: Bool = false

    private var cancellable: AnyCancellable? = nil
    
    @Published var fetchRequest: FetchRequest<Item>

    init() {
        self.fetchRequest = FetchRequest(
            entity: Item.entity(),
            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
            predicate: NSPredicate(
                format: "%K CONTAINS[C] %@ OR %K CONTAINS[C] %@",
                #keyPath(Item.title),
                "test",
                #keyPath(Item.feed.title),
                "test"
            )
        )
        
        cancellable = AnyCancellable(
            $query
                .removeDuplicates()
                .debounce(for: 0.8, scheduler: DispatchQueue.main)
                .sink { searchText in
                    if self.searchIsValid(query: searchText) {
                        self.fetchRequest = FetchRequest(
                            entity: Item.entity(),
                            sortDescriptors: [NSSortDescriptor(keyPath: \Item.published, ascending: false)],
                            predicate: NSPredicate(
                                format: "%K CONTAINS[C] %@ OR %K CONTAINS[C] %@",
                                #keyPath(Item.title),
                                searchText,
                                #keyPath(Item.feed.title),
                                searchText
                            )
                        )
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
    
}
