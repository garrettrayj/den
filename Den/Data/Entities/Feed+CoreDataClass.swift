//
//  Feed+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/19/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

@objc(Feed)
public class Feed: NSManagedObject {
    static let totalItemLimit = 20

    public var titleText: Text {
        if wrappedTitle == "" {
            return Text("Untitled", comment: "Default feed title.")
        } else {
            return Text(wrappedTitle)
        }
    }

    public var wrappedTitle: String {
        get { title ?? "" }
        set { title = newValue }
    }

    public var wrappedItemLimit: Int {
        get { Int(itemLimit) }
        set { itemLimit = Int16(newValue) }
    }

    public var itemLimitChoice: ItemLimit {
        get { ItemLimit(rawValue: wrappedItemLimit) ?? .six }
        set { wrappedItemLimit = newValue.rawValue }
    }

    public var feedData: FeedData? {
        (value(forKey: "feedData") as? [FeedData])?.first
    }

    public var urlString: String {
        get { url?.absoluteString ?? "" }
        set { url = URL(string: newValue) }
    }

    public var needsMetaUpdate: Bool {
        feedData?.metaFetched == nil
        || feedData!.metaFetched! < Date(timeIntervalSinceNow: -7 * 24 * 60 * 60)
    }

    public var isSecure: Bool {
        url?.scheme?.contains("https") == true
    }

    public var urlSchemeSymbol: String {
        isSecure ? "lock" : "lock.slash"
    }

    public var wrappedPreviewStyle: PreviewStyle {
        get { PreviewStyle(rawValue: Int(previewStyle)) ?? .compressed }
        set { previewStyle = Int16(newValue.rawValue) }
    }

    public var largePreviews: Bool {
        get { wrappedPreviewStyle == .expanded }
        set { wrappedPreviewStyle = newValue ? .expanded : .compressed }
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
        feed.itemLimitChoice = .six

        if prepend {
            feed.userOrder = page.feedsUserOrderMin - 1
        } else {
            feed.userOrder = page.feedsUserOrderMax + 1
        }

        return feed
    }
}

extension Collection where Element == Feed {
    func firstMatchingID(_ uuidString: String) -> Feed? {
        self.first { feed in
            feed.id?.uuidString == uuidString
        }
    }
}
