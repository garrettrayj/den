//
//  SaveFeedOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/26/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class SaveFeedOperation: Operation {
    // Operation inputs
    weak var workingFeed: WorkingFeedData?
    var workingFeedItems: [WorkingItem] = []

    unowned let feedObjectID: NSManagedObjectID
    unowned let persistentContainer: NSPersistentContainer
    let saveMeta: Bool

    init(
        persistentContainer: NSPersistentContainer,
        feedObjectID: NSManagedObjectID,
        saveMeta: Bool
    ) {
        self.persistentContainer = persistentContainer
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
            guard
                let feed = context.object(with: self.feedObjectID) as? Feed,
                let feedData = self.updateFeed(feed: feed, context: context)
            else { return }

            self.updateFeedItems(feed: feed, feedData: feedData, context: context)

            do {
                try context.save()
            } catch {
                Logger.main.error("SaveFeedOperation failed to save context")
                self.cancel()
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

        // Feed title is saved in FeedData for sorting search results
        feedData.feedTitle = feed.title

        if saveMeta == true {
            feedData.metaFetched = Date()

            feedData.favicon = workingFeed?.favicon

            workingFeed?.selectImage()
            feedData.image = workingFeed?.image
        }

        feedData.link = workingFeed?.link
        feedData.error = workingFeed?.error
        feedData.refreshed = Date()

        return feedData
    }

    private func updateFeedItems(feed: Feed, feedData: FeedData, context: NSManagedObjectContext) {
        // Sync history for existing items
        feedData.itemsArray.forEach { item in
            if item.read == false && !item.history.isEmpty {
                item.read = true
            }
        }

        // Add new items
        self.workingFeedItems.forEach { workingItem in
            let item = Item.create(moc: context, feedData: feedData)
            item.id = workingItem.id
            item.image = workingItem.image
            item.imageWidth = workingItem.imageWidth ?? 0
            item.imageHeight = workingItem.imageHeight ?? 0
            item.ingested = workingItem.ingested
            item.link = workingItem.link
            item.published = workingItem.published
            item.summary = workingItem.summary
            item.teaser = workingItem.teaser
            item.body = workingItem.body
            item.title = workingItem.title
            item.read = !item.history.isEmpty
            feedData.addToItems(item)
        }

        // Cleanup items
        guard
            let workingFeedItemCount = workingFeed?.itemCount,
            let feed = feedData.feed
        else {
            return
        }

        let maxItems = min(workingFeedItemCount, feed.wrappedItemLimit)
        if maxItems > 0 && feedData.itemsArray.count > maxItems {
            feedData.itemsArray.suffix(from: maxItems).forEach { item in
                feedData.removeFromItems(item)
                context.delete(item)
            }
        }
    }
}
