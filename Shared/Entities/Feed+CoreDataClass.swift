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
final public class Feed: NSManagedObject {
    static let totalItemLimit = 100
    
    var displayTitle: Text {
        if wrappedTitle == "" {
            return Text("Untitled", comment: "Default feed title.")
        }

        return Text(wrappedTitle)
    }

    var wrappedTitle: String {
        get { title?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { title = newValue }
    }

    var wrappedItemLimit: Int {
        get { Int(itemLimit) }
        set { itemLimit = Int16(newValue) }
    }

    var feedData: FeedData? {
        guard let id = self.id else { return nil }
        
        let request = FeedData.fetchRequest()
        request.predicate = NSPredicate(format: "feedId == %@", id as CVarArg)
        request.fetchLimit = 1
        
        return try? self.managedObjectContext?.fetch(request).first
    }

    var urlString: String {
        get { url?.absoluteString ?? "" }
        set { url = URL(string: newValue) }
    }
    
    var showExcerpts: Bool {
        get { !hideTeasers }
        set { hideTeasers = !newValue }
    }
    
    var showImages: Bool {
        get { !hideImages }
        set { hideImages = !newValue }
    }
    
    var showBylines: Bool {
        get { !hideBylines }
        set { hideBylines = !newValue }
    }
    
    var useBlocklists: Bool {
        get { !disableBlocklists }
        set { disableBlocklists = !newValue }
    }
    
    var allowJavaScript: Bool {
        get { !disableJavaScript }
        set { disableJavaScript = !newValue }
    }

    var needsMetaUpdate: Bool {
        feedData?.metaFetched == nil
        || feedData!.metaFetched! < Date(timeIntervalSinceNow: -7 * 24 * 60 * 60)
    }

    var isSecure: Bool {
        url?.scheme?.contains("https") == true
    }

    var urlSchemeSymbol: String {
        isSecure ? "lock" : "lock.slash"
    }
    
    var validatorURL: URL? {
        guard let urlEncoded = urlString.urlEncoded else { return nil }
            
        if feedData?.format == "JSON" {
            return URL(string: "https://validator.jsonfeed.org/?url=\(urlEncoded)")
        } else {
            return URL(string: "https://validator.w3.org/feed/check.cgi?url=\(urlEncoded)")
        }
    }

    var wrappedPreviewStyle: PreviewStyle {
        get { PreviewStyle(rawValue: Int(previewStyle)) ?? .compressed }
        set { previewStyle = Int16(newValue.rawValue) }
    }

    var largePreviews: Bool {
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
        feed.itemLimit = 6

        if prepend {
            feed.userOrder = page.feedsUserOrderMin - 1
        } else {
            feed.userOrder = page.feedsUserOrderMax + 1
        }

        return feed
    }
}
