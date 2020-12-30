//
//  DeduplicationOperation.swift
//  Den
//
//  Created by Garrett Johnson on 12/29/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit

class DeduplicationOperation: Operation {
    var feedObjectID: NSManagedObjectID
    
    private var persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer, feedObjectID: NSManagedObjectID) {
        self.persistentContainer = persistentContainer
        self.feedObjectID = feedObjectID
        super.init()
    }

    override func main() {
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        
        context.performAndWait {
            deduplicateFeedItems(context: context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    fatalError("Unable to save background context: \(error)")
                }
            }
        }
    }
    
    func deduplicateFeedItems(context: NSManagedObjectContext) {
        let feed = context.object(with: feedObjectID) as! Feed
        let crossReference = Dictionary(grouping: feed.itemsArray, by: { $0.link })
        let duplicates = crossReference
            .filter { $1.count > 1 }             // filter down to only those with multiple contacts
            .sorted { $0.1.count > $1.1.count }  // sort in descending order by number of duplicates
        
        duplicates.forEach { (link, item) in
            let duplicateGroup = feed.itemsArray.filter { item in
                item.link == link
            }
            
            duplicateGroup.suffix(from: 1).forEach { item in
                context.delete(item)
                feed.removeFromItems(item)
            }
        }
    }
}
