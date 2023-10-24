//
//  Profile+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson
//

import CoreData
import SwiftUI

@objc(Profile)
public class Profile: NSManagedObject {
    public var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    public var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Profile name placeholder.")
        }

        return Text(wrappedName)
    }

    public var exportTitle: String {
        if wrappedName != "" {
            return "\(wrappedName) \(Date().formatted(date: .abbreviated, time: .shortened))"
        }

        return "\(Date().formatted(date: .abbreviated, time: .shortened))"
    }

    public var wrappedHistoryRetention: Int {
        get { Int(historyRetention) }
        set { historyRetention = Int16(newValue) }
    }

    public var tintColor: Color? {
        guard let tint = tint, let tintOption = AccentColor(rawValue: tint) else { return nil }

        return tintOption.color
    }

    public var tintOption: AccentColor? {
        get {
            guard let tint = tint else { return nil }

            return AccentColor(rawValue: tint)
        }
        set {
            tint = newValue?.rawValue
        }
    }

    public var historyArray: [History] {
        get {
            history?.sortedArray(
                using: [NSSortDescriptor(key: "visited", ascending: false)]
            ) as? [History] ?? []
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
        predicates.append({ $0.title ?? "" < $1.title ?? "" })

        return values.sorted { lhs, rhs in
            for predicate in predicates {
                if !predicate(lhs, rhs) && !predicate(rhs, lhs) {
                    continue
                }
                return predicate(lhs, rhs)
            }

            return false
        }
    }

    public var pagesArray: [Page] {
        pages?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Page] ?? []
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

    public var tagsArray: [Tag] {
        tags?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Tag] ?? []
    }

    public var tagsUserOrderMin: Int16 {
        tagsArray.reduce(0) { (result, tag) -> Int16 in
            if tag.userOrder < result {
                return tag.userOrder
            }

            return result
        }
    }

    public var tagsUserOrderMax: Int16 {
        tagsArray.reduce(0) { (result, tag) -> Int16 in
            if tag.userOrder > result {
                return tag.userOrder
            }

            return result
        }
    }

    public var feedsArray: [Feed] {
        pagesArray.flatMap { $0.feedsArray }
    }

    public var feedCount: Int {
        feedsArray.count
    }

    public var searchesArray: [Search] {
        searches?.sortedArray(
            using: [NSSortDescriptor(key: "submitted", ascending: false)]
        ) as? [Search] ?? []
    }

    static func create(in managedObjectContext: NSManagedObjectContext) -> Profile {
        let newProfile = self.init(context: managedObjectContext)
        newProfile.id = UUID()
        newProfile.historyRetention = 90

        return newProfile
    }
}

extension Collection where Element == Profile {
    func firstMatchingID(_ uuidString: String?) -> Profile? {
        guard let uuidString = uuidString else { return nil }

        return self.first { $0.id?.uuidString == uuidString }
    }
}
