//
//  Blocklist+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI

@objc(Blocklist)
final public class Blocklist: NSManagedObject {
    var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default content filter name.")
        }

        return Text(wrappedName)
    }

    var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    var urlString: String {
        get { url?.absoluteString ?? "" }
        set { url = URL(string: newValue) }
    }

    var blocklistStatus: BlocklistStatus? {
        (value(forKey: "blocklistStatus") as? [BlocklistStatus])?.first
    }

    static func create(in managedObjectContext: NSManagedObjectContext) -> Blocklist {
        let blocklist = self.init(context: managedObjectContext)
        blocklist.id = UUID()

        return blocklist
    }
}
