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
    let refreshManager: RefreshManager

    private var lastBackgroundCleanup: Date?

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, refreshManager: RefreshManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.refreshManager = refreshManager
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

    func cleanup() {
        // Only perform cleanup if not refreshing
        if refreshManager.refreshing { return }

        // Only perform cleanup once every hour
        if let cleanupDate = lastBackgroundCleanup,
                cleanupDate > Date(timeIntervalSinceNow: -60 * 60) { return }

        cleanupHistory(context: viewContext)

        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                Logger.main.error("Saving background cleanup CoreData context failed")
            }
        }

        lastBackgroundCleanup = Date()
        Logger.main.info("cache.cleanup.finished")
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
