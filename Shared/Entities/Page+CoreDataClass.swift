//
//  Page+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

@objc(Page)
final public class Page: NSManagedObject {
    var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default page name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    var wrappedSymbol: String {
        get { symbol ?? "folder" }
        set { symbol = newValue }
    }

    var feedsArray: [Feed] {
        feeds?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Feed] ?? []
    }

    var feedsUserOrderMin: Int16 {
        feedsArray.reduce(0) { (result, feed) -> Int16 in
            if feed.userOrder < result {
                return feed.userOrder
            }

            return result
        }
    }

    var feedsUserOrderMax: Int16 {
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
}
