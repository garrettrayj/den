//
//  Profile+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData

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

    public var pagesWithInsecureFeeds: [Page] {
        pagesArray.filter { page in
            page.insecureFeeds.count > 0
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

    public var minimumRefreshedDate: Date? {
        pagesArray.filter({ $0.minimumRefreshedDate != nil }).sorted { aPage, bPage in
            if let aRefreshed = aPage.minimumRefreshedDate,
               let bRefreshed = bPage.minimumRefreshedDate {
                return aRefreshed < bRefreshed
            }
            return false
        }.first?.minimumRefreshedDate
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
        get {
            if let pages = self.pages?.sortedArray(
                using: [NSSortDescriptor(key: "userOrder", ascending: true)]
            ) as? [Page] {
                return pages
            }
            return []
        }
        set {
            pages = NSSet(array: newValue)
        }
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

    public var previewItems: [Item] {
        feedsArray.flatMap { (feed) -> [Item] in
            if let feedData = feed.feedData {
                return feedData.previewItems
            }
            return []
        }.sorted { $0.date > $1.date }
    }

    static func create(in managedObjectContext: NSManagedObjectContext) -> Profile {
        let newProfile = self.init(context: managedObjectContext)
        newProfile.id = UUID()
        newProfile.historyRetention = 90

        return newProfile
    }
}
