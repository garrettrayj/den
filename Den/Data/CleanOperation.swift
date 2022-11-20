//
//  CleanOperation.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

struct CleanOperation {
    unowned let container: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID
    
    let maxHistory = 100000

    func execute() async {
        let defaults = UserDefaults.standard

        await container.performBackgroundTask { context in
            guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }
            
            try? self.cleanupData(context: context)
            
            if
                let lastCleaned = defaults.object(forKey: "LastCleaned") as? Date,
                lastCleaned + 7 * 24 * 60 * 60 < .now
            {
                Logger.main.info("Performing history cleanup")
                try? self.cleanupHistory(context: context, profile: profile)
            }
            
            try? context.save()
        }
        
        defaults.set(Date.now, forKey: "LastCleaned")
    }

    private func cleanupHistory(context: NSManagedObjectContext, profile: Profile) throws {
        if profile.history?.count ?? 0 < maxHistory {
            Logger.main.info("History count does not exceed maximum records limit")
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

        Logger.main.info("History prune finished")
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
