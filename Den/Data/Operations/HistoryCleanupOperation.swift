//
//  HistoryCleanupOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

final class HistoryCleanupOperation: Operation {

    override func main() {
        PersistenceController.shared.container.performBackgroundTask { context in
            let fetchRequest = Profile.fetchRequest()
            guard let profiles = try? context.fetch(fetchRequest) as [Profile] else { return }
            for profile in profiles {
                try? self.cleanupHistory(context: context, profile: profile)
            }
            try? context.save()
        }
    }

    private func cleanupHistory(context: NSManagedObjectContext, profile: Profile) throws {
        if profile.historyRetention == 0 {
            Logger.main.info("""
            History cleanup skipped for profile: \(profile.wrappedName). \
            Retention period is unlimited
            """)
            return
        }

        let historyRetentionStart = Date() - Double(profile.historyRetention) * 24 * 60 * 60
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
        fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [
            NSPredicate(
                format: "%K < %@",
                #keyPath(History.visited),
                historyRetentionStart as NSDate
            ),
            NSPredicate(format: "%K = %@", #keyPath(History.profile), profile)
        ])

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
        Logger.main.info("History cleanup finished for profile: \(profile.wrappedName)")
    }
}
