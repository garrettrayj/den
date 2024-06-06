//
//  Profile.swift
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
class Profile {
    var created: Date?
    var historyRetention: Int16? = 0
    var id: UUID?
    var name: String?
    var tint: String?
    @Relationship(deleteRule: .cascade) var history: [History]?
    @Relationship(deleteRule: .cascade) var pages: [Page]?
    @Relationship(deleteRule: .cascade, inverse: \Search.profile) var searches: [Search]?
    @Relationship(deleteRule: .cascade, inverse: \Tag.profile) var tags: [Tag]?
    
    init(
        created: Date? = nil,
        historyRetention: Int16? = nil,
        id: UUID? = nil,
        name: String? = nil,
        tint: String? = nil,
        history: [History]? = nil,
        pages: [Page]? = nil,
        searches: [Search]? = nil,
        tags: [Tag]? = nil
    ) {
        self.created = created
        self.historyRetention = historyRetention
        self.id = id
        self.name = name
        self.tint = tint
        self.history = history
        self.pages = pages
        self.searches = searches
        self.tags = tags
    }
}
