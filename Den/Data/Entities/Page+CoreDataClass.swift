//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import SwiftUI

@objc(Page)
public class Page: NSManagedObject {
    public var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedName)
    }

    public var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    public var wrappedSymbol: String {
        get { symbol ?? "folder" }
        set { symbol = newValue }
    }

    public var wrappedItemsPerFeed: Int {
        get { Int(itemsPerFeed) }
        set { itemsPerFeed = Int16(newValue) }
    }

    public var feedsArray: [Feed] {
        feeds?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Feed] ?? []
    }

    public var feedsUserOrderMin: Int16 {
        feedsArray.reduce(0) { (result, feed) -> Int16 in
            if feed.userOrder < result {
                return feed.userOrder
            }

            return result
        }
    }

    public var feedsUserOrderMax: Int16 {
        feedsArray.reduce(0) { (result, feed) -> Int16 in
            if feed.userOrder > result {
                return feed.userOrder
            }

            return result
        }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        profile: Profile,
        prepend: Bool = false
    ) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.profile = profile
        newPage.created = Date()

        if prepend {
            newPage.userOrder = Int16(profile.pagesUserOrderMin - 1)
        } else {
            newPage.userOrder = Int16(profile.pagesUserOrderMax + 1)
        }

        return newPage
    }
}
