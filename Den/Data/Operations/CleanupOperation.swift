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
    unowned let persistentContainer: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID

    let maxHistory = 100000

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
        if profile.history?.count ?? 0 < maxHistory {
            Logger.main.info("Skipping history cleanup")
            return
        }

        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.predicate = NSPredicate(format: "%K = %@", #keyPath(History.profile), profile)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(History.visited), ascending: false)]
        fetchRequest.fetchOffset = maxHistory

        // Create a batch delete request for the fetch request
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        // Specify the result of the NSBatchDeleteRequest
        // should be the NSManagedObject IDs for the deleted objects
        deleteRequest.resultType = .resultTypeObjectIDs

        // Perform the batch delete
        let batchDelete = try? context.execute(deleteRequest) as? NSBatchDeleteResult

        guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { return }

        let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]

        // Merge the delete changes into the managed object context
        NSManagedObjectContext.mergeChanges(
            fromRemoteContextSave: deletedObjects,
            into: [context]
        )

        Logger.main.info("History cleanup finished")
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
