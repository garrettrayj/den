//
//  History+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/16/21.
//  Copyright © 2021 Garrett Johnson
//

import CoreData

@objc(History)
public class History: NSManagedObject {
    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> History {
        let history = self.init(context: managedObjectContext)
        history.id = UUID()
        history.profile = profile

        return history
    }
}
