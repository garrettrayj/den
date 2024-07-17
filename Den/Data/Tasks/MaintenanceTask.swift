//
//  MaintenanceTask.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

struct MaintenanceTask {
    func execute(container: NSPersistentContainer) async {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergePolicy(merge: .mergeByPropertyObjectTrumpMergePolicyType)
        
        context.performAndWait {
            trimHistory(context: context)
            trimSearches(context: context)

            do {
                try context.save()
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Maintained")
                Logger.main.info("Maintenance operations completed")
            } catch {
                Logger.main.error("Saving maintenance task context failed with error: \(error)")
            }
        }
        
        await BlocklistManager.cleanupContentRulesLists(container: container)
        await BlocklistManager.refreshAllContentRulesLists(container: container)
    }
    
    private func trimHistory(context: NSManagedObjectContext) {
        DataController.truncate(
            History.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \History.visited, ascending: false)],
            offset: 100000
        )
    }
    
    private func trimSearches(context: NSManagedObjectContext) {
        DataController.truncate(
            Search.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \Search.submitted, ascending: false)],
            offset: 20
        )
    }
}
