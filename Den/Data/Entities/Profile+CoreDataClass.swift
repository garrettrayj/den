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
final public class Profile: NSManagedObject {
    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Profile name placeholder.")
        }

        return Text(wrappedName)
    }

    var exportTitle: String {
        if wrappedName != "" {
            return "\(wrappedName) \(Date().formatted(date: .abbreviated, time: .shortened))"
        }

        return "\(Date().formatted(date: .abbreviated, time: .shortened))"
    }

    var wrappedHistoryRetention: Int {
        get { Int(historyRetention) }
        set { historyRetention = Int16(newValue) }
    }

    var tintColor: Color? {
        guard let tint = tint, let tintOption = AccentColor(rawValue: tint) else { return nil }

        return tintOption.color
    }

    var tintOption: AccentColor? {
        get {
            guard let tint = tint else { return nil }

            return AccentColor(rawValue: tint)
        }
        set {
            tint = newValue?.rawValue
        }
    }

    var historyArray: [History] {
        get {
            history?.sortedArray(
                using: [NSSortDescriptor(key: "visited", ascending: false)]
            ) as? [History] ?? []
        }
        set {
            history = NSSet(array: newValue)
        }
    }

    var pagesArray: [Page] {
        pages?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Page] ?? []
    }

    var pagesUserOrderMin: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder < result {
                return page.userOrder
            }

            return result
        }
    }

    var pagesUserOrderMax: Int16 {
        pagesArray.reduce(0) { (result, page) -> Int16 in
            if page.userOrder > result {
                return page.userOrder
            }

            return result
        }
    }

    var tagsArray: [Tag] {
        tags?.sortedArray(
            using: [NSSortDescriptor(key: "userOrder", ascending: true)]
        ) as? [Tag] ?? []
    }

    var tagsUserOrderMin: Int16 {
        tagsArray.reduce(0) { (result, tag) -> Int16 in
            if tag.userOrder < result {
                return tag.userOrder
            }

            return result
        }
    }

    var tagsUserOrderMax: Int16 {
        tagsArray.reduce(0) { (result, tag) -> Int16 in
            if tag.userOrder > result {
                return tag.userOrder
            }

            return result
        }
    }

    var feedsArray: [Feed] {
        pagesArray.flatMap { $0.feedsArray }
    }

    var feedCount: Int {
        feedsArray.count
    }

    var searchesArray: [Search] {
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
