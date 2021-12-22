//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/19/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

@objc(Feed)
public class Feed: NSManagedObject {
    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var wrappedItemLimit: Int {
        get {
            if itemLimit == 0 {
                // Get default from page
                itemLimit = 20
            }
            return Int(itemLimit)
        }
        set {
            itemLimit = Int16(newValue)
            if previewLimit > itemLimit {
                previewLimit = itemLimit
            }
        }
    }

    public var wrappedPreviewLimit: Int {
        get {
            if previewLimit == 0 {
                // Get default from page
                previewLimit = Int16(page?.wrappedItemsPerFeed ?? 6)
            }
            return Int(previewLimit)
        }
        set {
            previewLimit = Int16(newValue)
            if previewLimit >= itemLimit {
                itemLimit = previewLimit
            }

        }
    }

    public var feedData: FeedData? {
        let values = value(forKey: "feedData") as? [FeedData]

        if let unwrappedValues = values {
            return unwrappedValues.first
        }

        return nil
    }

    public var refreshed: String? {
        guard let refreshedDate = feedData?.refreshed else {
            return nil
        }

        return DateFormatter.mediumShort.string(from: refreshedDate)
    }

    public var urlString: String {
        get {url?.absoluteString ?? ""}
        set {url = URL(string: newValue)}
    }

    public var urlSchemeSymbol: String {
        if url?.scheme?.contains("https") == true {
            return "lock"
        }

        return "lock.slash"
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        page: Page,
        url: URL,
        prepend: Bool = false
    ) -> Feed {
        let feed = self.init(context: managedObjectContext)
        feed.id = UUID()
        feed.page = page
        feed.url = url
        feed.showThumbnails = true
        feed.itemLimit = 12
        feed.previewLimit = 6

        if prepend {
            feed.userOrder = page.feedsUserOrderMin - 1
        } else {
            feed.userOrder = page.feedsUserOrderMax + 1
        }

        return feed
    }
}
