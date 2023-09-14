//
//  Bookmark+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

@objc(Bookmark)
public class Bookmark: NSManagedObject {
    @objc
    public var date: Date {
        published ?? Date(timeIntervalSince1970: 0)
    }

    public var wrappedTitle: String {
        get {title ?? "Untitled"}
        set {title = newValue}
    }

    public var wrappedAuthor: String {
        get {author ?? "Untitled"}
        set {author = newValue}
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
        bookmark.body = item.body
        bookmark.summary = item.summary
        bookmark.teaser = item.teaser
        bookmark.author = item.author
        bookmark.image = item.image
        bookmark.imageHeight = item.imageHeight
        bookmark.imageWidth = item.imageWidth
        bookmark.link = item.link
        bookmark.published = item.published

        return bookmark
    }
}
