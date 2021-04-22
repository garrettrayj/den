//
//  SaveFeedOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import FeedKit
import OSLog
import UIKit
import Combine

import func AVFoundation.AVMakeRect

class SaveFeedOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeed?
    var workingFeedItems: [WorkingFeedItem] = []
    
    private var subscriptionObjectID: NSManagedObjectID
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    private var saveMeta: Bool
    
    init(persistentContainer: NSPersistentContainer, crashManager: CrashManager, subscriptionObjectID: NSManagedObjectID, saveMeta: Bool) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
        self.subscriptionObjectID = subscriptionObjectID
        self.saveMeta = saveMeta
        super.init()
    }
    
    override func main() {        
        if isCancelled { return }
        
        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.performAndWait {
            let subscription = context.object(with: subscriptionObjectID) as! Subscription
            guard let feed = updateFeed(subscription: subscription, context: context) else { return }
            
            updateFeedItems(feed: feed, context: context)
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    DispatchQueue.main.async {
                        self.crashManager.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
    
    func updateFeed(subscription: Subscription, context: NSManagedObjectContext) -> Feed? {
        guard let feed = subscription.feed else {
            return nil
        }
        
        if subscription.title == nil {
            subscription.title = workingFeed?.title
        }
        
        if saveMeta == true {
            feed.favicon = self.workingFeed?.favicon
            feed.faviconLocal = self.workingFeed?.faviconLocal
            feed.metaFetched = Date()
        }
        
        feed.error = self.workingFeed?.error
        feed.refreshed = Date()
        
        return feed
    }
    
    func updateFeedItems(feed: Feed, context: NSManagedObjectContext) {
        self.workingFeedItems.forEach { workingItem in
            let item = Item.init(context: context)
            item.id = workingItem.id
            item.image = workingItem.image
            item.imageLocal = workingItem.imageLocal
            item.ingested = workingItem.ingested
            item.link = workingItem.link
            item.published = workingItem.published
            item.summary = workingItem.summary
            item.title = workingItem.title
            
            feed.addToItems(item)
        }
    }
}
