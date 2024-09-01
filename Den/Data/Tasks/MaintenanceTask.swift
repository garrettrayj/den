//
//  MaintenanceTask.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/24.
//  Copyright © 2024 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

struct MaintenanceTask {
    static func execute() async {
        let context = DataController.shared.container.newBackgroundContext()
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
        
        await BlocklistManager.cleanupContentRulesLists()
        await BlocklistManager.refreshAllContentRulesLists()
    }
    
    private static func trimHistory(context: NSManagedObjectContext) {
        DataController.truncate(
            History.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \History.visited, ascending: false)],
            offset: 100000
        )
    }
    
    private static func trimSearches(context: NSManagedObjectContext) {
        DataController.truncate(
            Search.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \Search.submitted, ascending: false)],
            offset: 20
        )
    }
}
