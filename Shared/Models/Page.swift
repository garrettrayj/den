//
//  Page.swift
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
class Page {
    var created: Date?
    var id: UUID?
    var itemsPerFeed: Int16 = 5
    var name: String?
    var symbol: String?
    var userOrder: Int16 = 0
    @Relationship(deleteRule: .cascade, inverse: \Feed.page) var feeds: [Feed]?
    var profile: Profile?
    
    init(
        created: Date? = nil,
        id: UUID? = nil,
        itemsPerFeed: Int16,
        name: String? = nil,
        symbol: String? = nil,
        userOrder: Int16,
        feeds: [Feed]? = nil,
        profile: Profile? = nil
    ) {
        self.created = created
        self.id = id
        self.itemsPerFeed = itemsPerFeed
        self.name = name
        self.symbol = symbol
        self.userOrder = userOrder
        self.feeds = feeds
        self.profile = profile
    }
    
    var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    var wrappedSymbol: String {
        get { symbol ?? "folder" }
        set { symbol = newValue }
    }
    
    var wrappedFeeds: [Feed] {
        feeds ?? []
    }

    var sortedFeeds: [Feed] {
        wrappedFeeds.sorted(using: [SortDescriptor(\.userOrder)])
    }

    var feedsUserOrderMin: Int16 {
        feeds?.reduce(0) { (result, feed) -> Int16 in
            if (feed.userOrder ?? 0) < result {
                return feed.userOrder ?? 0
            }

            return result
        } ?? 0
    }

    var feedsUserOrderMax: Int16 {
        feeds?.reduce(0) { (result, feed) -> Int16 in
            if (feed.userOrder ?? 0) > result {
                return feed.userOrder ?? 0
            }

            return result
        } ?? 0
    }

    static func create(
        in modelContext: ModelContext,
        userOrder: Int16
    ) -> Page {
        let newPage = Page(itemsPerFeed: 100, userOrder: 0)
        newPage.id = UUID()
        newPage.created = Date()
        newPage.userOrder = userOrder
        
        modelContext.insert(newPage)

        return newPage
    }
}

extension Collection where Element == Page {
    var feeds: [Feed] {
        self.reduce([]) { partialResult, page in
            partialResult + page.sortedFeeds
        }
    }
    
    var maxUserOrder: Int16 {
        self.reduce(0) { partialResult, tag in
            tag.userOrder > partialResult ? tag.userOrder : partialResult
        }
    }
}
