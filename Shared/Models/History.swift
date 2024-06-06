//
//  History.swift
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
class History {
    var id: UUID?
    var link: URL?
    var title: String?
    var visited: Date?
    var profile: Profile?
    
    init(
        id: UUID? = nil,
        link: URL? = nil,
        title: String? = nil,
        visited: Date? = nil,
        profile: Profile? = nil
    ) {
        self.id = id
        self.link = link
        self.title = title
        self.visited = visited
        self.profile = profile
    }
    
    static func create(in modelContext: ModelContext) -> History {
        let history = History()
        history.id = UUID()

        modelContext.insert(history)
        
        return history
    }
}
