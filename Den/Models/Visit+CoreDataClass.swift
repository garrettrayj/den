//
//  Visit+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 1/16/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

@objc(Visit)
public class Visit: NSManagedObject {
    static func create(in managedObjectContext: NSManagedObjectContext) -> Visit {
        let visit = self.init(context: managedObjectContext)
        visit.id = UUID()
        
        return visit
    }
}
