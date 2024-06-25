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
        
        await BlocklistManager.cleanupContentRulesLists()
        await BlocklistManager.refreshAllContentRulesLists()

        do {
            try context.save()
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "Maintained")
            Logger.main.info("Maintenance operations completed")
        } catch {
            Logger.main.error("Saving maintenance task context failed with error: \(error)")
        }
    }
    
    private func trimHistory(context: ModelContext) {
        var fetchDescriptor = FetchDescriptor<History>(
            sortBy: [SortDescriptor(\.visited, order: .reverse)]
        )
        fetchDescriptor.fetchOffset = 100000
        
        guard let history = try? context.fetch(fetchDescriptor) else {
            return
        }
        
        for record in history {
            context.delete(record)
        }
    }
    
    private func trimSearches(context: ModelContext) {
        var fetchDescriptor = FetchDescriptor<Search>(
            sortBy: [SortDescriptor(\.submitted, order: .reverse)]
        )
        fetchDescriptor.fetchOffset = 20
        
        guard let searches = try? context.fetch(fetchDescriptor) else {
            return
        }
        
        for search in searches {
            context.delete(search)
        }
    }
}
