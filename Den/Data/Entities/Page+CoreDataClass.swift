//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
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
        userOrder: Int16
    ) -> Page {
        let newPage = self.init(context: managedObjectContext)
        newPage.id = UUID()
        newPage.created = Date()
        newPage.userOrder = userOrder

        return newPage
    }
}

extension Collection where Element == Page {    
    var feeds: [Feed] {
        self.reduce([]) { partialResult, page in
            partialResult + page.feedsArray
        }
    }
    
    var maxUserOrder: Int16 {
        self.reduce(0) { partialResult, tag in
            tag.userOrder > partialResult ? tag.userOrder : partialResult
        }
    }
    
    var minUserOrder: Int16 {
        self.reduce(0) { partialResult, tag in
            tag.userOrder < partialResult ? tag.userOrder : partialResult
        }
    }
}
