//
//  FeedData.swift
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
class FeedData {
    var age: String?
    var banner: URL?
    var cacheControl: String?
    var copyright: String?
    var error: String?
    var eTag: String?
    var favicon: URL?
    var faviconFile: String?
    var feedId: UUID?
    var feedTitle: String?
    var format: String?
    var httpStatus: Int16? = 0
    var icon: URL?
    var id: UUID?
    var image: URL?
    var link: URL?
    var metaDescription: String?
    var metaFetched: Date?
    var refreshed: Date?
    var responseTime: Float? = 0.0
    var server: String?
    @Relationship(deleteRule: .cascade, inverse: \Item.feedData) var items: [Item]?
    
    init(
        age: String? = nil,
        banner: URL? = nil,
        cacheControl: String? = nil,
        copyright: String? = nil,
        error: String? = nil,
        eTag: String? = nil,
        favicon: URL? = nil,
        faviconFile: String? = nil,
        feedId: UUID? = nil,
        feedTitle: String? = nil,
        format: String? = nil,
        httpStatus: Int16? = nil,
        icon: URL? = nil,
        id: UUID? = nil,
        image: URL? = nil,
        link: URL? = nil,
        metaDescription: String? = nil,
        metaFetched: Date? = nil,
        refreshed: Date? = nil,
        responseTime: Float? = nil,
        server: String? = nil,
        items: [Item]? = nil
    ) {
        self.age = age
        self.banner = banner
        self.cacheControl = cacheControl
        self.copyright = copyright
        self.error = error
        self.eTag = eTag
        self.favicon = favicon
        self.faviconFile = faviconFile
        self.feedId = feedId
        self.feedTitle = feedTitle
        self.format = format
        self.httpStatus = httpStatus
        self.icon = icon
        self.id = id
        self.image = image
        self.link = link
        self.metaDescription = metaDescription
        self.metaFetched = metaFetched
        self.refreshed = refreshed
        self.responseTime = responseTime
        self.server = server
        self.items = items
    }
    
    enum RefreshError: String {
        case request
        case parsing
    }
    
    var wrappedError: RefreshError? {
        get {
            guard let error = error else { return nil }
            return RefreshError(rawValue: error)
        }
        set {
            error = newValue?.rawValue
        }
    }
    
    var wrappedItems: [Item] {
        items ?? []
    }

    var sortedItems: [Item] {
        items?.sorted(using: [
            SortDescriptor(\.published, order: .reverse),
            SortDescriptor(\.title, order: .forward)
        ]) as? [Item] ?? []
    }

    var feed: Feed? {
        var fetchDescriptor = FetchDescriptor<Feed>()
        fetchDescriptor.predicate = #Predicate<Feed> { $0.id == feedId }
        
        return try? modelContext?.fetch(fetchDescriptor).first
    }

    static func create(in modelContext: ModelContext, feedId: UUID) -> FeedData {
        let feedData = FeedData()
        feedData.id = UUID()
        feedData.feedId = feedId
        
        modelContext.insert(feedData)

        return feedData
    }
}
