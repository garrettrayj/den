//
//  Profile+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

@objc(Profile)
public class Profile: NSManagedObject {
    public var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    public var displayName: String {
        name == nil || name == "" ? "Untitled" : name!
    }

    public var wrappedHistoryRetention: Int {
        get { Int(historyRetention) }
        set { historyRetention = Int16(newValue) }
    }

    public var tintUIColor: UIColor? {
        guard let tint = tint, let tintOption = TintOption(rawValue: tint) else { return nil }
        return tintOption.uiColor
    }

    public var tintColor: Color? {
        guard let tint = tint, let tintOption = TintOption(rawValue: tint) else { return nil }
        return tintOption.color
    }

    public var wrappedPreviewStyle: PreviewStyle {
        get {
            PreviewStyle(rawValue: Int(previewStyle)) ?? .compressed
        }
        set {
            previewStyle = Int16(newValue.rawValue)
        }
    }

    public var wrappedItemLimit: Int {
        get {
            if itemLimit == 0 {
                itemLimit = Int16(AppDefaults.defaultItemLimit)
            }
            return Int(itemLimit)
        }
        set {
            itemLimit = Int16(newValue)
        }
    }

    public var pagesWithInsecureFeeds: [Page] {
        pagesArray.filter { page in
            page.insecureFeeds.count > 0
        }
    }

    public var feedCountString: String {
        if self.feedsArray.count == 1 {
            return "1 Feed"
        } else {
            return "\(self.feedsArray.count) Feeds"
        }
    }

    public var insecureFeeds: [Feed] {
        pagesArray.flatMap { page in
            return page.insecureFeeds
        }
    }

    public var insecureFeedCount: Int {
        insecureFeeds.count
    }

    public var historyArray: [History] {
        get {
            guard
                let history = self.history?.sortedArray(
                    using: [NSSortDescriptor(key: "visited", ascending: false)]
                ) as? [History]
            else { return [] }

            return history
        }
        set {
            history = NSSet(array: newValue)
        }
    }

    public var trends: [Trend] {
        guard
            let values = value(forKey: "trends") as? [Trend]
        else { return [] }

        typealias AreInIncreasingOrder = (Trend, Trend) -> Bool

        var predicates: [AreInIncreasingOrder] = []
        predicates.append({ $0.items.count > $1.items.count })
        predicates.append({ $0.wrappedTitle < $1.wrappedTitle })

        return values.sorted { lhs, rhs in
            for predicate in predicates {
                if !predicate(lhs, rhs) && !predicate(rhs, lhs) { // <4>
                    continue
                }
                return predicate(lhs, rhs)
            }

            return false
        }
    }

    public var pagesArray: [Page] {
        if let pages = self.pages?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Page] {
            return pages
        }
        return []
    }

    public var pagesUserOrderMin: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder < result {
                return page.userOrder
            }
            return result
        }
    }

    public var pagesUserOrderMax: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder > result {
                return page.userOrder
            }
            return result
        }
    }

    public var feedsArray: [Feed] {
        pagesArray.flatMap { $0.feedsArray }
    }

    static func create(in managedObjectContext: NSManagedObjectContext) -> Profile {
        let newProfile = self.init(context: managedObjectContext)
        newProfile.id = UUID()
        newProfile.historyRetention = 90

        return newProfile
    }
}

extension Collection where Element == Profile {
    func firstMatchingID(_ uuidString: String) -> Profile? {
        self.first { profile in
            profile.id?.uuidString == uuidString
        }
    }
}
