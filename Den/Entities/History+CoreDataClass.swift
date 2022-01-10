//
//  History+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/16/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData

@objc(History)
public class History: NSManagedObject {
    /** This could be a stored property for better performance */
    @objc
    var day: String {
        guard let visited = visited else { return "Unknown" }
        return DateFormatter.fullNone.string(from: visited)
    }

    static func create(in managedObjectContext: NSManagedObjectContext, profile: Profile) -> History {
        let history = self.init(context: managedObjectContext)
        history.id = UUID()
        history.profile = profile

        return history
    }
}
