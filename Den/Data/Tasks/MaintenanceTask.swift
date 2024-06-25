//
//  MaintenanceTask.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog

struct MaintenanceTask {
    func execute() async {
        let context = ModelContext(DataController.shared.container)
        
        trimHistory(context: context)
        trimSearches(context: context)
        
        await BlocklistManager.cleanupContentRulesLists(context: context)
        await BlocklistManager.refreshAllContentRulesLists(context: context)

        do {
            try context.save()
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Maintained")
            Logger.main.info("Maintenance operations completed")
        } catch {
            Logger.main.error("Saving maintenance task context failed with error: \(error)")
        }
    }
    
    private func trimHistory(context: ModelContext) {
        /*
        DataController.truncate(
            History.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \History.visited, ascending: false)],
            offset: 100000
        )
         */
    }
    
    private func trimSearches(context: ModelContext) {
        /*
        DataController.truncate(
            Search.self,
            context: context,
            sortDescriptors: [NSSortDescriptor(keyPath: \Search.submitted, ascending: false)],
            offset: 20
        )
         */
    }
}
