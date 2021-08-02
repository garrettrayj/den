//
//  SearchManager.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation

final class SearchManager: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [[Item]] = []
    @Published var historyResults: [[History]] = []

    func reset() {
        searchQuery = ""
    }

    func trimQuery() {
        searchQuery = searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func searchIsValid() -> Bool {
        if searchQuery == "" || searchQuery.count >= 3 {
            return true
        }

        return false
    }
}
