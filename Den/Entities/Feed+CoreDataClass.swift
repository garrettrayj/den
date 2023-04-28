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
    public var wrappedTitle: String {
        get {title ?? "Untitled"}
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
        let values = value(forKey: "feedData") as? [FeedData]

        if let unwrappedValues = values {
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

    public var cascadedItemLimit: Int {
        if customPreviews {
            return self.wrappedItemLimit
        }

        return self.page?.profile?.wrappedItemLimit ?? AppDefaults.defaultItemLimit
    }

    public var cascadedPreviewStyle: PreviewStyle {
        if customPreviews {
            return self.wrappedPreviewStyle
        }

        return self.page?.profile?.wrappedPreviewStyle ?? .compressed
    }

    public var cascadedHideImages: Bool {
        if customPreviews {
            return self.hideImages
        }

        return self.page?.profile?.hideImages ?? false
    }

    public var cascadedHideTeasers: Bool {
        if customPreviews {
            return self.hideTeasers
        }

        return self.page?.profile?.hideTeasers ?? false
    }

    public var cascadedBrowserView: Bool {
        if customPreviews {
            return self.browserView
        }

        return self.page?.profile?.browserView ?? false
    }

    public var cascadedReaderMode: Bool {
        if customPreviews {
            return self.readerMode
        }

        return self.page?.profile?.readerMode ?? false
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
