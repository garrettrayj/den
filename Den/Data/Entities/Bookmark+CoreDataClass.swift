//
//  Bookmark+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import SwiftUI

@objc(Bookmark)
public class Bookmark: NSManagedObject {
    public var titleText: Text {
        if wrappedTitle == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedTitle)
    }

    public var wrappedTitle: String {
        get { title?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { title = newValue }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        item: Item,
        tag: Tag
    ) -> Bookmark {
        let bookmark = self.init(context: managedObjectContext)
        bookmark.id = UUID()
        bookmark.tag = tag
        bookmark.feed = item.feedData?.feed
        bookmark.title = item.title
        bookmark.teaser = item.teaser
        bookmark.author = item.author
        bookmark.image = item.image
        bookmark.imageHeight = item.imageHeight
        bookmark.imageWidth = item.imageWidth
        bookmark.link = item.link
        bookmark.published = item.published
        bookmark.ingested = item.ingested

        return bookmark
    }
}
