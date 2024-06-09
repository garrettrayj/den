//
//  Tag.swift
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
import SwiftUI

@Model 
class Tag {
    var id: UUID?
    var name: String?
    var userOrder: Int16? = 0
    @Relationship(deleteRule: .cascade) var bookmarks: [Bookmark]?
    var profile: Profile?
    
    init(
        id: UUID? = nil,
        name: String? = nil,
        userOrder: Int16? = nil,
        bookmarks: [Bookmark]? = nil,
        profile: Profile? = nil
    ) {
        self.id = id
        self.name = name
        self.userOrder = userOrder
        self.bookmarks = bookmarks
        self.profile = profile
    }
    
    var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default tag name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    static func create(
        in modelContext: ModelContext,
        userOrder: Int16
    ) -> Tag {
        let tag = Tag()
        tag.id = UUID()
        tag.userOrder = userOrder
        
        modelContext.insert(tag)

        return tag
    }
}

extension Collection where Element == Tag {
    var maxUserOrder: Int16 {
        self.reduce(0) { partialResult, tag in
            (tag.userOrder ?? 0) > partialResult ? (tag.userOrder ?? 0) : partialResult
        }
    }
}
