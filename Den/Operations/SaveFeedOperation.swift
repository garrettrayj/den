//
//  SaveFeedOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

import func AVFoundation.AVMakeRect

final class SaveFeedOperation: Operation {
    // Operation inputs
    var workingFeed: WorkingFeedData?
    var workingFeedItems: [WorkingItem] = []

    private var feedObjectID: NSManagedObjectID
    private var persistentContainer: NSPersistentContainer
    private var crashManager: CrashManager
    private var saveMeta: Bool

    init(
        persistentContainer: NSPersistentContainer,
        crashManager: CrashManager,
        feedObjectID: NSManagedObjectID,
        saveMeta: Bool
    ) {
        self.persistentContainer = persistentContainer
        self.crashManager = crashManager
        self.feedObjectID = feedObjectID
        self.saveMeta = saveMeta
        super.init()
    }

    override func main() {
        if isCancelled { return }

        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = false
        context.performAndWait {
            guard let feed = context.object(with: feedObjectID) as? Feed else { return }
            guard let feedData = updateFeed(feed: feed, context: context) else { return }

            updateFeedItems(feedData: feedData, context: context)

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

    private func updateFeed(feed: Feed, context: NSManagedObjectContext) -> FeedData? {
        guard let feedData = feed.feedData else {
            return nil
        }

        if feed.title == nil {
            feed.title = workingFeed?.title
        }

        if saveMeta == true {
            feedData.favicon = self.workingFeed?.favicon
            feedData.faviconFile = self.workingFeed?.faviconFile
            feedData.metaFetched = Date()
        }

        feedData.link = self.workingFeed?.link
        feedData.error = self.workingFeed?.error
        feedData.refreshed = Date()

        return feedData
    }

    private func updateFeedItems(feedData: FeedData, context: NSManagedObjectContext) {
        self.workingFeedItems.forEach { workingItem in
            let item = Item.init(context: context)
            item.feedData = feedData
            item.id = workingItem.id
            item.image = workingItem.image
            item.imageFile = workingItem.imageFile
            item.ingested = workingItem.ingested
            item.link = workingItem.link
            item.published = workingItem.published
            item.summary = workingItem.summary
            item.title = workingItem.title
        }
    }
}
