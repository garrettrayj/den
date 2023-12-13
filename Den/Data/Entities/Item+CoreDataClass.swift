//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import NaturalLanguage
import SwiftUI

@objc(Item)
public class Item: NSManagedObject {
    public var titleText: Text {
        if let title = title, title != "" {
            return Text(title)
        }

        return Text("Untitled", comment: "Default item title.")
    }
    
    public var profile: Profile? {
        (value(forKey: "profile") as? [Profile])?.first
    }

    public var history: [History] {
        value(forKey: "history") as? [History] ?? []
    }

    public var bookmarks: [Bookmark] {
        value(forKey: "bookmarks") as? [Bookmark] ?? []
    }

    public var bookmarkTags: [Tag] {
        Array(Set(bookmarks.compactMap { $0.tag }))
    }

    public var wrappedTags: [(String, NLTag)] {
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

    public var trendItemsArray: [TrendItem] {
        get { trendItems?.allObjects as? [TrendItem] ?? [] }
        set { trendItems = NSSet(array: newValue) }
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

    public func anaylyzeTitleTags() {
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
    func forFeed(feed: Feed) -> [Item] {
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

    func read() -> [Item] {
        self.filter { $0.read == true }
    }

    func unread() -> [Item] {
        self.filter { $0.read == false }
    }

    func previews() -> [Item] {
        self.filter { $0.extra == false }
    }

    func extras() -> [Item] {
        self.filter { $0.extra == true }
    }
}
