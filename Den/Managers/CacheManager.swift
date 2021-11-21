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
    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
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
        if
            let cleanupDate = lastBackgroundCleanup,
                cleanupDate > Date(timeIntervalSinceNow: -60 * 60)
        { return }

        cleanupHistory(context: viewContext)
        cleanupFeedsAndImages(context: viewContext)

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

    private func cleanupFeedsAndImages(context: NSManagedObjectContext) {
        guard let faviconsDirectory = FileManager.default.faviconsDirectory else { return }
        var cleanFeedDatas: [FeedData] = []

        do {
            let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]

            for feedData in feedDatas {
                if feedData.feed == nil {
                    context.delete(feedData)
                    continue
                }

                let itemLimit = 100
                if feedData.itemsArray.count > itemLimit {
                    let oldItems = feedData.itemsArray.suffix(from: itemLimit)
                    oldItems.forEach { context.delete($0) }
                }

                cleanFeedDatas.append(feedData)
            }

            let activeFavicons: [URL] = cleanFeedDatas.compactMap { feedData in
                if let filename = feedData.faviconFile {
                    return faviconsDirectory.appendingPathComponent(filename).absoluteURL
                }
                return nil
            }
            self.cleanupCacheDirectory(cacheDirectory: faviconsDirectory, activeFileList: activeFavicons)

            let items: [Item] = cleanFeedDatas.flatMap { $0.itemsArray }

            cleanupItemImages(items)
        } catch {
            crashManager.handleCriticalError(error as NSError)
        }

    }

    private func cleanupItemImages(_ items: [Item]) {
        guard
            let previewsDirectory = FileManager.default.previewsDirectory,
            let thumbnailsDirectory = FileManager.default.thumbnailsDirectory
        else { return }

        let activePreviews: [URL] = items.compactMap { item in
            if let filename = item.imagePreview {
                return previewsDirectory.appendingPathComponent(filename).absoluteURL
            }
            return nil
        }
        self.cleanupCacheDirectory(cacheDirectory: previewsDirectory, activeFileList: activePreviews)

        let activeThumbnails: [URL] = items.compactMap { item in
            if let filename = item.imageThumbnail {
                return thumbnailsDirectory.appendingPathComponent(filename).absoluteURL
            }
            return nil
        }
        self.cleanupCacheDirectory(cacheDirectory: thumbnailsDirectory, activeFileList: activeThumbnails)
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

    private func cleanupCacheDirectory(cacheDirectory: URL, activeFileList: [URL]) {
        let resourceKeys: [URLResourceKey] = [.creationDateKey, .isDirectoryKey]

        do {
            let cacheContents = try FileManager.default.contentsOfDirectory(
                at: cacheDirectory,
                includingPropertiesForKeys: resourceKeys
            )
            cacheContents.forEach { cachedFile in
                if !activeFileList.contains(cachedFile.standardizedFileURL) {
                    do {
                        try FileManager.default.removeItem(at: cachedFile)
                    } catch {
                        Logger.main.error("Unable to remove file: \(error as NSError)")
                    }
                }
            }
        } catch {
            Logger.main.error("Unable to read cache directory contents: \(error as NSError)")
        }
    }
}
