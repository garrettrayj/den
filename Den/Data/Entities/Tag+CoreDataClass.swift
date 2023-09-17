//
//  Tag+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

@objc(Tag)
public class Tag: NSManagedObject {
    public var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default tag name.")
        }

        return Text(wrappedName.replacingOccurrences(of: " ", with: "\u{00A0}"))
    }

    public var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    public var bookmarksArray: [Bookmark] {
        get {
            guard
                let bookmarks = self.bookmarks?.sortedArray(
                    using: [NSSortDescriptor(key: "published", ascending: false)]
                ) as? [Bookmark]
            else { return [] }

            return bookmarks
        }
        set {
            bookmarks = NSSet(array: newValue)
        }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        profile: Profile
    ) -> Tag {
        let tag = self.init(context: managedObjectContext)
        tag.id = UUID()
        tag.profile = profile

        tag.userOrder = Int16(profile.tagsUserOrderMax + 1)

        return tag
    }
}
