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

            let trends = try viewContext.fetch(Trend.fetchRequest()) as [Trend]
            trends.forEach { trend in
                viewContext.delete(trend)
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
}
