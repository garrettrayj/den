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

    @objc
    public var feedTitle: String {
        feedData?.feed?.wrappedTitle ?? "Untitled"
    }

    @objc
    public var day: String {
        date.formatted(date: .complete, time: .omitted)
    }

    @objc
    public var date: Date {
        published ?? ingested ?? Date(timeIntervalSince1970: 0)
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
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

    public var imageAspectRatio: CGFloat? {
        guard imageWidth > 0, imageHeight > 0 else { return nil }
        return CGFloat(imageWidth) / CGFloat(imageHeight)
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
    func firstMatchingID(_ uuidString: String) -> Item? {
        self.first { item in
            item.id?.uuidString == uuidString
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
}
