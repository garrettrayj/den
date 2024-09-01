//
//  Tag+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 9/12/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

@objc(Tag)
final public class Tag: NSManagedObject {
    var displayName: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default tag name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name?.trimmingCharacters(in: .whitespaces) ?? "" }
        set { name = newValue }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext,
        userOrder: Int16
    ) -> Tag {
        let tag = self.init(context: managedObjectContext)
        tag.id = UUID()
        tag.userOrder = userOrder

        return tag
    }
}

extension Collection where Element == Tag {
    var maxUserOrder: Int16 {
        self.reduce(0) { partialResult, tag in
            tag.userOrder > partialResult ? tag.userOrder : partialResult
        }
    }
}
