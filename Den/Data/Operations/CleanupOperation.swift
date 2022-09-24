//
//  CleanupOperation.swift
//  Den
//
//  Created by Garrett Johnson on 9/24/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData
import OSLog

/**
 Finds trending tags
 */
final class CleanupOperation: Operation {
    let persistentContainer: NSPersistentContainer
    let profileObjectID: NSManagedObjectID

    init(
        persistentContainer: NSPersistentContainer,
        profileObjectID: NSManagedObjectID
    ) {
        self.persistentContainer = persistentContainer
        self.profileObjectID = profileObjectID
        super.init()
    }

    override func main() {
        if isCancelled { return }

        let context = persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }

            do {
                try cleanupHistory(context: context, profile: profile)
                try cleanupData(context: context)
                try context.save()
            } catch {
                self.cancel()
            }
        }
    }

    private func cleanupHistory(context: NSManagedObjectContext, profile: Profile) throws {
        var itemsRemoved: Int = 0
        if profile.historyRetention == 0 { return }
        let historyRetentionStart = Date() - Double(profile.historyRetention) * 24 * 60 * 60
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.predicate = NSPredicate(
            format: "%K < %@",
            #keyPath(History.visited),
            historyRetentionStart as NSDate
        )
        fetchRequest.sortDescriptors = []

        let fetchResults = try context.fetch(fetchRequest) as? [History]
        fetchResults?.forEach { context.delete($0) }
        itemsRemoved += fetchResults?.count ?? 0
        Logger.main.info("History cleanup finished. \(itemsRemoved) entries removed")
    }

    /**
     Remove abandoned FeedData entities. Related Item entities will also be removed via cascade.
     */
    private func cleanupData(context: NSManagedObjectContext) throws {
        var orphansPurged = 0
        let feedDatas = try context.fetch(FeedData.fetchRequest()) as [FeedData]
        for feedData in feedDatas where feedData.feed == nil {
            context.delete(feedData)
            orphansPurged += 1
        }
        Logger.main.info("Purged \(orphansPurged) orphaned feed data caches")
    }
}
