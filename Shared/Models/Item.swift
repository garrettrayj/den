//
//  Item.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import NaturalLanguage
import SwiftData
import SwiftUI

@Model 
class Item {
    var author: String?
    var body: String?
    var bookmarked: Bool?
    var extra: Bool?
    var id: UUID?
    var image: URL?
    var imageFile: String?
    var imageHeight: Int32? = 0
    var imagePreview: String?
    var imageThumbnail: String?
    var imageWidth: Int32? = 0
    var ingested: Date?
    var link: URL?
    var profileId: UUID?
    var published: Date?
    var read: Bool? = false
    var summary: String?
    var tags: String?
    var teaser: String?
    var title: String?
    var feedData: FeedData?
    @Relationship(deleteRule: .cascade, inverse: \TrendItem.item) var trendItems: [TrendItem]?
    
    init(
        author: String? = nil,
        body: String? = nil,
        bookmarked: Bool? = nil,
        extra: Bool? = nil,
        id: UUID? = nil,
        image: URL? = nil,
        imageFile: String? = nil,
        imageHeight: Int32? = nil,
        imagePreview: String? = nil,
        imageThumbnail: String? = nil,
        imageWidth: Int32? = nil,
        ingested: Date? = nil,
        link: URL? = nil,
        profileId: UUID? = nil,
        published: Date? = nil,
        read: Bool? = nil,
        summary: String? = nil,
        tags: String? = nil,
        teaser: String? = nil,
        title: String? = nil,
        feedData: FeedData? = nil,
        trendItems: [TrendItem]? = nil
    ) {
        self.author = author
        self.body = body
        self.bookmarked = bookmarked
        self.extra = extra
        self.id = id
        self.image = image
        self.imageFile = imageFile
        self.imageHeight = imageHeight
        self.imagePreview = imagePreview
        self.imageThumbnail = imageThumbnail
        self.imageWidth = imageWidth
        self.ingested = ingested
        self.link = link
        self.profileId = profileId
        self.published = published
        self.read = read
        self.summary = summary
        self.tags = tags
        self.teaser = teaser
        self.title = title
        self.feedData = feedData
        self.trendItems = trendItems
    }
    
    var titleText: Text {
        if let title = title, title != "" {
            return Text(title)
        }

        return Text("Untitled", comment: "Default item title.")
    }
    
    var profile: Profile? {
        nil
    }

    var history: [History] {
        var fetchDescriptor = FetchDescriptor<History>()
        fetchDescriptor.predicate = #Predicate<History>{ $0.link == link }
        
        return (try? modelContext?.fetch(fetchDescriptor)) ?? []
    }

    var bookmarks: [Bookmark] {
        var fetchDescriptor = FetchDescriptor<Bookmark>()
        fetchDescriptor.predicate = #Predicate<Bookmark>{ $0.link == link }
        
        return (try? modelContext?.fetch(fetchDescriptor)) ?? []
    }

    var bookmarkTags: [Tag] {
        Array(Set(bookmarks.compactMap { $0.tag }).sorted(using: SortDescriptor(\.userOrder)))
    }

    var wrappedTags: [(String, NLTag)] {
        get {
            var results: [(String, NLTag)] = []
            let decoder = JSONDecoder()

            if
                let json = tags?.data(using: .utf8),
                let rawTags = try? decoder.decode([[String]].self, from: json)
            {
                for rawTag in rawTags {
                    results.append((rawTag[0], NLTag(rawValue: rawTag[1])))
                }
            }

            return results
        }
        set {
            var encodableValue: [[String]] = []
            for (title, tag) in newValue {
                encodableValue.append([title, tag.rawValue])
            }
            if let data = try? JSONSerialization.data(withJSONObject: encodableValue) {
                tags = String(data: data, encoding: String.Encoding.utf8)
            }
        }
    }

    var trendItemsArray: [TrendItem] {
        get { trendItems ?? [] }
        set { trendItems = newValue }
    }
    
    var trends: [Trend] {
        trendItemsArray.compactMap { $0.trend }
    }
    
    var wrappedRead: Bool {
        get { read ?? false }
        set { read = newValue }
    }

    static func create(moc modelContext: ModelContext, feedData: FeedData) -> Item {
        let item = Item()
        item.id = UUID()
        item.feedData = feedData
        item.profileId = feedData.feed?.page?.profile?.id
        item.read = false
        item.ingested = Date()
        
        modelContext.insert(item)

        return item
    }
    
    func populateImage(imagePool: [PreliminaryImage]) {
        guard let selectedImage = imagePool.first else { return }
    
        image = selectedImage.url
        if let width = selectedImage.width, let height = selectedImage.height {
            imageWidth = Int32(width)
            imageHeight = Int32(height)
        }
    }

    func anaylyzeTitleTags() {
        guard let text = title else { return }
        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let allowedTags: [NLTag] = [.personalName, .placeName, .organizationName]

        var results: [(String, NLTag)] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, tokenRange in
            if let tag = tag, allowedTags.contains(tag) {
                results.append((String(text[tokenRange]), tag))
            }

            return true
        }

        wrappedTags = results
    }
}

extension Collection where Element == Item {
    func forFeed(_ feed: Feed) -> [Item] {
        self.filter { $0.feedData?.id == feed.feedData?.id }
    }

    func visibilityFiltered(_ readFilter: Bool?) -> [Item] {
        self.filter { item in
            if readFilter == false {
                return item.read == false
            } else if readFilter == true {
                return item.read == true
            }

            return true
        }
    }

    var unread: [Item] {
        self.filter { $0.read == false }
    }

    var featured: [Item] {
        self.filter { $0.extra == false }
    }

    var extra: [Item] {
        self.filter { $0.extra == true }
    }
}
