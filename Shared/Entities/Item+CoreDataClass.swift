//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import NaturalLanguage
import SwiftUI

@objc(Item)
final public class Item: NSManagedObject {
    var titleText: Text {
        if let title = title, title != "" {
            return Text(title)
        }

        return Text("Untitled", comment: "Default item title.")
    }

    var history: [History] {
        guard let link = link else { return [] }
        
        let request = History.fetchRequest()
        request.predicate = NSPredicate(format: "link == %@", link as CVarArg)
        
        let history = try? self.managedObjectContext?.fetch(request) as? [History]
        
        return history ?? []
    }

    var bookmarks: [Bookmark] {
        guard let link = link else { return [] }
        
        let request = Bookmark.fetchRequest()
        request.predicate = NSPredicate(format: "link == %@", link as CVarArg)
        
        let bookmarks = try? self.managedObjectContext?.fetch(request) as? [Bookmark]
        
        return bookmarks ?? []
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
                tags = String(decoding: data, as: UTF8.self)
            }
        }
    }

    var trendItemsArray: [TrendItem] {
        get { trendItems?.allObjects as? [TrendItem] ?? [] }
        set { trendItems = NSSet(array: newValue) }
    }
    
    var trends: [Trend] {
        trendItemsArray.compactMap { $0.trend }
    }

    static func create(moc managedObjectContext: NSManagedObjectContext, feedData: FeedData) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feedData = feedData
        item.profileId = feedData.feed?.page?.profile?.id
        item.read = false
        item.ingested = Date()

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
