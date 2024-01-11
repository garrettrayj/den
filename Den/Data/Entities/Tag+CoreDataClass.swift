//
//  Tag+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson
//

import CoreData
import SwiftUI

@objc(Tag)
public class Tag: NSManagedObject {
    public var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default tag name.")
        }

        return Text(wrappedName)
    }

    public var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    public var bookmarksArray: [Bookmark] {
        bookmarks?.sortedArray(
            using: [NSSortDescriptor(key: "published", ascending: false)]
        ) as? [Bookmark] ?? []
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
