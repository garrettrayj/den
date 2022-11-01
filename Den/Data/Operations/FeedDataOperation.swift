//
//  FeedDataOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation

import CoreData
import OSLog

final class FeedDataOperation: Operation {
    var existingItemLinks: [URL] = []
    
    unowned let feedObjectID: NSManagedObjectID
    unowned let persistentContainer: NSPersistentContainer

    init(
        persistentContainer: NSPersistentContainer,
        feedObjectID: NSManagedObjectID
    ) {
        self.persistentContainer = persistentContainer
        self.feedObjectID = feedObjectID
        super.init()
    }

    override func main() {
        if isCancelled { return }
        
        self.persistentContainer.performBackgroundTask { context in
            guard let feed = context.object(with: self.feedObjectID) as? Feed else { return }
            self.existingItemLinks = self.checkFeedData(context: context, feed: feed)
        }
    }
    
    func checkFeedData(context: NSManagedObjectContext, feed: Feed) -> [URL] {
        if feed.feedData == nil {
            guard let feedId = feed.id else { return [] }
            let _ = FeedData.create(in: context, feedId: feedId)
            do {
                try context.save()
            } catch {
                self.cancel()
            }
            return []
        }
        
        return feed.feedData?.itemsArray.compactMap({ item in
            return item.link
        }) ?? []
    }
}




