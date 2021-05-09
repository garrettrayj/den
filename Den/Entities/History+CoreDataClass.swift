//
//  History+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/16/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(History)
public class History: NSManagedObject {
    static func create(in managedObjectContext: NSManagedObjectContext) -> History {
        let history = self.init(context: managedObjectContext)
        history.id = UUID()
        
        return history
    }
}
