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
public class Blocklist: NSManagedObject {
    public var nameText: Text {
        if wrappedName == "" {
            return Text("Untitled", comment: "Default content filter name.")
        }

        return Text(wrappedName)
    }

    public var wrappedName: String {
        get { name ?? "" }
        set { name = newValue }
    }

    static func create(
        in managedObjectContext: NSManagedObjectContext
    ) -> Blocklist {
        let blocklist = self.init(context: managedObjectContext)
        blocklist.id = UUID()

        return blocklist
    }
}
