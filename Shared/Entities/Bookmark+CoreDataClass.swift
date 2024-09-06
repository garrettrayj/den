//
//  Bookmark+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

@objc(Bookmark)
final public class Bookmark: NSManagedObject {
    var titleText: Text {
        if wrappedTitle == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedTitle)
    }

    var wrappedTitle: String {
        get { title?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { title = newValue }
    }
    
    var siteText: Text {
        if wrappedSite == "" {
            return Text("Untitled", comment: "Bookmark site title placeholder.")
        }

        return Text(wrappedSite)
    }

    var wrappedSite: String {
        get { site?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { site = newValue }
    }
    
    var wrappedHideByline: Bool {
        if let feedHideBylines = feed?.hideBylines {
            return feedHideBylines
        } else {
            return hideByline
        }
    }
    
    var wrappedHideTeaser: Bool {
        if let feedHideTeaser = feed?.hideTeasers {
            return feedHideTeaser
        } else {
            return hideTeaser
        }
    }
    
    var wrappedHideImage: Bool {
        if let feedHideImage = feed?.hideImages {
            return feedHideImage
        } else {
            return hideImage
        }
    }
    
    var wrappedLargePreview: Bool {
        if let feedLargePreview = feed?.largePreviews {
            return feedLargePreview
        } else {
            return largePreview
        }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        item: Item,
        tag: Tag? = nil
    ) -> Bookmark {
        let bookmark = self.init(context: managedObjectContext)
        bookmark.id = UUID()
        bookmark.tag = tag
        bookmark.feed = item.feedData?.feed
        bookmark.site = item.feedData?.feed?.title
        bookmark.favicon = item.feedData?.favicon
        bookmark.hideImage = item.feedData?.feed?.hideImages ?? false
        bookmark.hideByline = item.feedData?.feed?.hideBylines ?? false
        bookmark.hideTeaser = item.feedData?.feed?.hideTeasers ?? false
        bookmark.largePreview = item.feedData?.feed?.largePreviews ?? false
        bookmark.title = item.title
        bookmark.teaser = item.teaser
        bookmark.author = item.author
        bookmark.image = item.image
        bookmark.imageHeight = item.imageHeight
        bookmark.imageWidth = item.imageWidth
        bookmark.link = item.link
        bookmark.published = item.published
        bookmark.ingested = item.ingested
        bookmark.created = .now

        return bookmark
    }
}
