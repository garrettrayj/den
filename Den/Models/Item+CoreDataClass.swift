//
//  Item+CoreDataClass.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import HTMLEntities

@objc(Item)
public class Item: NSManagedObject {
    public var wrappedTitle: String {
        get{title ?? "Untitled"}
        set{title = newValue}
    }
    
    func markRead() {
        if read == true { return }
        read = true
        
        // Update unread count capsules
        self.feed?.page?.objectWillChange.send()
        
        do {
            try self.managedObjectContext?.save()
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}

extension Item: Identifiable {
    
}

extension Item {
    
}
