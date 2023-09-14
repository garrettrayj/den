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
import SwiftUI
import OSLog
import NaturalLanguage

import HTMLEntities

@objc(Item)
public class Item: NSManagedObject {
    public var history: [History] {
        value(forKey: "history") as? [History] ?? []
    }

    public var bookmarks: [Bookmark] {
        value(forKey: "bookmarks") as? [Bookmark] ?? []
    }

    public var bookmarkTags: [Tag] {
        get {
            bookmarks.compactMap { $0.tag }
        }
        set {
            guard let context = managedObjectContext else { return }
            for bookmark in bookmarks {
                if let existingTag = bookmark.tag, !newValue.contains(existingTag) {
                    context.delete(bookmark)
                }
            }
            for tag in newValue {
                guard !bookmarkTags.contains(tag) else { continue }
                _ = Bookmark.create(in: context, item: self, tag: tag)
            }
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    @objc
    public var date: Date {
        published ?? ingested ?? Date(timeIntervalSince1970: 0)
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var wrappedAuthor: String {
        get {author ?? "Untitled"}
        set {author = newValue}
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
        get {
            trendItems?.allObjects as? [TrendItem] ?? []
        }
        set {
            trendItems = NSSet(array: newValue)
        }
    }

    static func create(moc managedObjectContext: NSManagedObjectContext, feedData: FeedData) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feedData = feedData
        item.profileId = feedData.feed?.page?.profile?.id
        item.read = false

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
    func forPage(page: Page) -> [Item] {
        self.filter { item in
            page.feedsArray.compactMap { $0.feedData }.contains(item.feedData)
        }
    }

    func forFeed(feed: Feed) -> [Item] {
        self.filter { item in
            item.feedData == feed.feedData
        }
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
        self.filter { item in
            item.read == true
        }
    }

    func unread() -> [Item] {
        self.filter { item in
            item.read == false
        }
    }

    func previews() -> [Item] {
        self.filter { $0.extra == false }
    }

    func extras() -> [Item] {
        self.filter { $0.extra == true }
    }
}
