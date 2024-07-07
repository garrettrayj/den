//
//  Bookmark.swift
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
class Bookmark {
    var author: String?
    var body: String?
    var created: Date?
    var favicon: URL?
    var hideByline: Bool?
    var hideImage: Bool?
    var hideTeaser: Bool?
    var id: UUID?
    var image: URL?
    var imageHeight: Int32? = 0
    var imageWidth: Int32? = 0
    var ingested: Date?
    var itemId: UUID?
    var largePreview: Bool?
    var link: URL?
    var published: Date?
    var site: String?
    var summary: String?
    var teaser: String?
    var title: String?
    var feed: Feed?
    var tag: Tag?
    
    init(
        author: String? = nil,
        body: String? = nil,
        created: Date? = nil,
        favicon: URL? = nil,
        hideByline: Bool? = nil,
        hideImage: Bool? = nil,
        hideTeaser: Bool? = nil,
        id: UUID? = nil,
        image: URL? = nil,
        imageHeight: Int32? = nil,
        imageWidth: Int32? = nil,
        ingested: Date? = nil,
        itemId: UUID? = nil,
        largePreview: Bool? = nil,
        link: URL? = nil,
        published: Date? = nil,
        site: String? = nil,
        summary: String? = nil,
        teaser: String? = nil,
        title: String? = nil,
        feed: Feed? = nil,
        tag: Tag? = nil
    ) {
        self.author = author
        self.body = body
        self.created = created
        self.favicon = favicon
        self.hideByline = hideByline
        self.hideImage = hideImage
        self.hideTeaser = hideTeaser
        self.id = id
        self.image = image
        self.imageHeight = imageHeight
        self.imageWidth = imageWidth
        self.ingested = ingested
        self.itemId = itemId
        self.largePreview = largePreview
        self.link = link
        self.published = published
        self.site = site
        self.summary = summary
        self.teaser = teaser
        self.title = title
        self.feed = feed
        self.tag = tag
    }
    
    var titleText: Text {
        if wrappedTitle == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedTitle)
    }

    var wrappedTitle: String {
        get { title?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { title = newValue }
    }
    
    var siteText: Text {
        if wrappedSite == "" {
            return Text("Untitled", comment: "Bookmark site title placeholder.")
        }

        return Text(wrappedSite)
    }

    var wrappedSite: String {
        get { site?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { site = newValue }
    }
    
    var item: Item? {
        var fetchDescriptor = FetchDescriptor<Item>()
        fetchDescriptor.predicate = #Predicate<Item> { $0.id == itemId }
        fetchDescriptor.fetchLimit = 1
        
        return try? modelContext?.fetch(fetchDescriptor).first
    }

    static func create(
        in modelContext: ModelContext,
        item: Item,
        tag: Tag? = nil
    ) -> Bookmark {
        let bookmark = Bookmark()
        bookmark.id = UUID()
        bookmark.tag = tag
        bookmark.feed = item.feedData?.feed
        bookmark.site = item.feedData?.feed?.title
        bookmark.favicon = item.feedData?.favicon
        bookmark.hideImage = item.feedData?.feed?.hideImages ?? false
        bookmark.hideByline = item.feedData?.feed?.hideBylines ?? false
        bookmark.hideTeaser = item.feedData?.feed?.hideTeasers ?? false
        bookmark.largePreview = item.feedData?.feed?.largePreviews ?? false
        bookmark.title = item.title
        bookmark.teaser = item.teaser
        bookmark.author = item.author
        bookmark.image = item.image
        bookmark.imageHeight = item.imageHeight
        bookmark.imageWidth = item.imageWidth
        bookmark.itemId = item.id
        bookmark.link = item.link
        bookmark.published = item.published
        bookmark.ingested = item.ingested
        bookmark.created = .now
        
        modelContext.insert(bookmark)

        return bookmark
    }
}
