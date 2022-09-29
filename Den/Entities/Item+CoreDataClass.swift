//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
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
        date.fullNoneDisplay()
    }

    @objc
    public var date: Date {
        published ?? ingested ?? Date(timeIntervalSince1970: 0)
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var imageAspectRatio: CGFloat? {
        guard imageWidth > 0, imageHeight > 0 else { return nil }
        return CGFloat(imageWidth) / CGFloat(imageHeight)
    }

    static func create(moc managedObjectContext: NSManagedObjectContext, feedData: FeedData) -> Item {
        let item = Item.init(context: managedObjectContext)
        item.id = UUID()
        item.feedData = feedData
        item.profileId = feedData.feed?.page?.profile?.id

        return item
    }

    public func subjects() -> [(String, NLTag)] {
        guard let text = title else { return [] }

        let tagger = NLTagger(tagSchemes: [.nameType])
        tagger.string = text

        let options: NLTagger.Options = [.omitPunctuation, .omitWhitespace, .joinNames]
        let tags: [NLTag] = [.personalName, .placeName, .organizationName]

        var subjects: [(String, NLTag)] = []

        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .nameType,
            options: options
        ) { tag, tokenRange in
            if let tag = tag, tags.contains(tag) {
                subjects.append((String(text[tokenRange]), tag))
            }

            return true
        }

        return subjects
    }
}

extension Array where Element == Item {
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
