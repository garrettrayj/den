//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import FeedKit
import OSLog
import SwiftUI

@objc(FeedData)
public class FeedData: NSManagedObject {
    struct FeedIngestMeta {
        var thumbnails: [URL] = []
    }

    public var feed: Feed? {
        let values = value(forKey: "feed") as? [Feed]
        if let unwrappedValues = values {
            return unwrappedValues.first
        }

        return nil
    }

    public var itemsArray: [Item] {
        guard
            let items = items?.sortedArray(
                using: [
                    NSSortDescriptor(key: "published", ascending: false),
                    NSSortDescriptor(key: "ingested", ascending: false)
                ]
            ) as? [Item]
        else { return [] }

        return items
    }

    public var limitedItemsArray: ArraySlice<Item> {
        itemsArray.prefix(feed?.wrappedItemLimit ?? 6)
    }

    public var itemsWithImageCount: Int {
        itemsArray.filter({ item in
            item.image != nil
        }).count
    }

    public var linkDisplayString: String? {
        guard let link = link else { return nil }

        return link.absoluteString
            .replacingOccurrences(of: "http://", with: "")
            .replacingOccurrences(of: "https://", with: "")
            .trimmingCharacters(in: .init(charactersIn: "/"))
    }

    public var faviconImage: Image? {
        guard
            let faviconsDirectory = FileManager.default.faviconsDirectory,
            let filename = self.faviconFile
        else { return nil }

        let filepath = faviconsDirectory.appendingPathComponent(filename)

        do {
            let imageData = try Data(contentsOf: filepath)
            if let uiImage = UIImage(data: imageData, scale: UIScreen.main.scale) {
                return Image(uiImage: uiImage)
            }
        } catch {
            Logger.main.notice("Error loading favicon image: \(error.localizedDescription)")
        }

        return nil
    }

    static func create(in managedObjectContext: NSManagedObjectContext, feedId: UUID) -> FeedData {
        let newFeed = self.init(context: managedObjectContext)
        newFeed.id = UUID()
        newFeed.feedId = feedId

        return newFeed
    }
}
