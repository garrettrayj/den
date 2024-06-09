//
//  Feed.swift
//  Den
//
//  Created by Garrett Johnson on 6/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//
//

import Foundation
import SwiftData
import SwiftUI

@Model 
class Feed {
    var browserView: Bool?
    var disableBlocklists: Bool?
    var disableJavaScript: Bool?
    var hideBylines: Bool?
    var hideImages: Bool?
    var hideTeasers: Bool?
    var id: UUID?
    var itemLimit: Int16? = 100
    var previewLimit: Int16? = 4
    var previewStyle: Int16? = 0
    var readerMode: Bool?
    var showThumbnails: Bool?
    var title: String?
    var url: URL?
    var userOrder: Int16? = 0
    var bookmarks: [Bookmark]?
    var page: Page?
    
    init(
        browserView: Bool? = nil,
        disableBlocklists: Bool? = nil,
        disableJavaScript: Bool? = nil,
        hideBylines: Bool? = nil,
        hideImages: Bool? = nil,
        hideTeasers: Bool? = nil,
        id: UUID? = nil,
        itemLimit: Int16? = nil,
        previewLimit: Int16? = nil,
        previewStyle: Int16? = nil,
        readerMode: Bool? = nil,
        showThumbnails: Bool? = nil,
        title: String? = nil,
        url: URL? = nil,
        userOrder: Int16? = nil,
        bookmarks: [Bookmark]? = nil,
        page: Page? = nil
    ) {
        self.browserView = browserView
        self.disableBlocklists = disableBlocklists
        self.disableJavaScript = disableJavaScript
        self.hideBylines = hideBylines
        self.hideImages = hideImages
        self.hideTeasers = hideTeasers
        self.id = id
        self.itemLimit = itemLimit
        self.previewLimit = previewLimit
        self.previewStyle = previewStyle
        self.readerMode = readerMode
        self.showThumbnails = showThumbnails
        self.title = title
        self.url = url
        self.userOrder = userOrder
        self.bookmarks = bookmarks
        self.page = page
    }
    
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
        get { Int(itemLimit ?? 0) }
        set { itemLimit = Int16(newValue) }
    }

    var feedData: FeedData? {
        var fetchDescriptor = FetchDescriptor<FeedData>()
        fetchDescriptor.predicate = #Predicate<FeedData> { $0.feedId == id }
        
        return try? modelContext?.fetch(fetchDescriptor).first
    }

    var urlString: String {
        get { url?.absoluteString ?? "" }
        set { url = URL(string: newValue) }
    }
    
    var showExcerpts: Bool {
        get { !(hideTeasers ?? false) }
        set { hideTeasers = !newValue }
    }
    
    var showImages: Bool {
        get { !(hideImages ?? false) }
        set { hideImages = !newValue }
    }
    
    var showBylines: Bool {
        get { !(hideBylines ?? false) }
        set { hideBylines = !newValue }
    }
    
    var useBlocklists: Bool {
        get { !(disableBlocklists ?? false) }
        set { disableBlocklists = !newValue }
    }
    
    var allowJavaScript: Bool {
        get { !(disableJavaScript ?? false) }
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
        get { PreviewStyle(rawValue: Int(previewStyle ?? 0)) ?? .compressed }
        set { previewStyle = Int16(newValue.rawValue) }
    }
    
    var wrappedReaderMode: Bool {
        get { readerMode ?? false }
        set { readerMode = newValue }
    }

    var largePreviews: Bool {
        get { wrappedPreviewStyle == .expanded }
        set { wrappedPreviewStyle = newValue ? .expanded : .compressed }
    }

    static func create(
        in modelContext: ModelContext,
        page: Page,
        url: URL,
        prepend: Bool = false
    ) -> Feed {
        let feed = Feed()
        feed.id = UUID()
        feed.page = page
        feed.url = url
        feed.itemLimit = 6

        if prepend {
            feed.userOrder = page.feedsUserOrderMin - 1
        } else {
            feed.userOrder = page.feedsUserOrderMax + 1
        }
        
        modelContext.insert(feed)

        return feed
    }
}
