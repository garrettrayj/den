//
//  Search.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import SwiftData

@Model
class Search {
    var id: UUID?
    var query: String?
    var submitted: Date?
    var profile: Profile?

    init(
        id: UUID? = nil,
        query: String? = nil,
        submitted: Date? = nil,
        profile: Profile? = nil
    ) {
        self.id = id
        self.query = query
        self.submitted = submitted
        self.profile = profile
    }
    
    var wrappedQuery: String {
        query ?? ""
    }

    static func create(
        in modelContext: ModelContext,
        query: String
    ) -> Search {
        let search = Search()
        search.id = UUID()
        search.submitted = Date()
        search.query = query
        
        modelContext.insert(search)

        return search
    }
}
