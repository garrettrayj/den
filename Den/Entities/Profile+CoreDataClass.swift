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
        get { name ?? "Untitled" }
        set { name = newValue }
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

    public var pagesArray: [Page] {
        get {
            guard
                let pages = self.pages?.sortedArray(
                    using: [NSSortDescriptor(key: "userOrder", ascending: true)]
                ) as? [Page]
            else { return [] }

            return pages
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

    static func create(in managedObjectContext: NSManagedObjectContext) -> Profile {
        let newProfile = self.init(context: managedObjectContext)
        newProfile.id = UUID()
        newProfile.name = "New Profile"

        return newProfile
    }
}
