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

@objc(Feed)
public class Feed: NSManagedObject {
    public var displayTitle: String? {
        wrappedTitle == "" ? nil : wrappedTitle
    }

    public var wrappedTitle: String {
        get {title ?? ""}
        set {title = newValue}
    }

    public var wrappedItemLimit: Int {
        get {
            return Int(itemLimit)
        }
        set {
            itemLimit = Int16(newValue)
        }
    }

    public var feedData: FeedData? {
        if let unwrappedValues = self.value(forKey: "feedData") as? [FeedData] {
            return unwrappedValues.first
        }

        return nil
    }

    public var urlString: String {
        get {url?.absoluteString ?? ""}
        set {url = URL(string: newValue)}
    }

    public var needsMetaUpdate: Bool {
        if feedData?.metaFetched == nil ||
            feedData!.metaFetched! < Date(timeIntervalSinceNow: -7 * 24 * 60 * 60) {
            return true
        }
        return false
    }

    public var urlSchemeSymbol: String {
        if url?.scheme?.contains("https") == true {
            return "lock"
        }

        return "lock.slash"
    }

    public var wrappedPreviewStyle: PreviewStyle {
        get {
            PreviewStyle(rawValue: Int(previewStyle)) ?? .compressed
        }
        set {
            previewStyle = Int16(newValue.rawValue)
        }
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
        feed.wrappedPreviewStyle = .compressed
        feed.hideImages = false
        feed.hideTeasers = false
        feed.itemLimit = Int16(AppDefaults.defaultItemLimit)

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
