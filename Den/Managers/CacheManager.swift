//
//  CacheManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/8/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class CacheManager: ObservableObject {
    let viewContext: NSManagedObjectContext
    let crashManager: CrashManager

    private var lastBackgroundCleanup: Date?

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
    }

    func resetFeeds() {
        do {
            let pages = try viewContext.fetch(Page.fetchRequest()) as [Page]
            pages.forEach { page in
                page.feedsArray.forEach { feed in
                    if let feedData = feed.feedData {
                        viewContext.delete(feedData)
                    }
                }
            }

            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch {
                    DispatchQueue.main.async {
                        self.crashManager.handleCriticalError(error as NSError)
                    }
                }
            }
        } catch {
            self.crashManager.handleCriticalError(error as NSError)
        }
    }

    func performBackgroundCleanup() {
        // Only perform background cleanup every hour
        if let cleanupDate = lastBackgroundCleanup,
                cleanupDate > Date(timeIntervalSinceNow: -60 * 60) { return }

        cleanupHistory(context: viewContext)
        cleanupFeeds(context: viewContext)

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                Logger.main.error("Saving background cleanup CoreData context failed")
            }
        }

        lastBackgroundCleanup = Date()
        Logger.main.info("Background cleanup finished")
    }

    private func cleanupFeeds(context: NSManagedObjectContext) {
        do {
            let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]

            for feedData in feedDatas {
                if feedData.feed == nil {
                    context.delete(feedData)
                    continue
                }

                let itemLimit = feedData.feed?.wrappedItemLimit ?? 0
                if feedData.itemsArray.count > itemLimit {
                    let oldItems = feedData.itemsArray.suffix(from: itemLimit)
                    oldItems.forEach { context.delete($0) }
                }
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }

    private func cleanupHistory(context: NSManagedObjectContext) {
        do {
            let profiles = try context.fetch(Profile.fetchRequest()) as [Profile]
            profiles.forEach { profile in
                if profile.historyRetention == 0 { return }
                let historyRetentionStart = Date().addingTimeInterval(-Double(profile.historyRetention) * 24 * 60 * 60)
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
                fetchRequest.predicate = NSPredicate(
                    format: "%K < %@",
                    #keyPath(History.visited),
                    historyRetentionStart as NSDate
                )
                fetchRequest.sortDescriptors = []

                do {
                    guard let fetchResults = try context.fetch(fetchRequest) as? [History] else { return }
                    fetchResults.forEach { context.delete($0) }
                } catch {
                    crashManager.handleCriticalError(error as NSError)
                }
            }
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }
    }
}
