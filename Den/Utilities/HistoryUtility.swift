//
//  HistoryUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI
import WidgetKit

struct HistoryUtility {
    static func markItemRead(
        context: NSManagedObjectContext,
        item: Item
    ) {
        guard item.read == false else { return }

        let history = History.create(in: context)
        history.link = item.link
        history.visited = .now

        item.read = true
        item.trends.forEach { $0.updateReadStatus() }

        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    static func markItemUnread(
        context: NSManagedObjectContext,
        item: Item
    ) {
        guard item.read == true else { return }

        for history in item.history {
            context.delete(history)
        }

        item.read = false
        item.trends.forEach { $0.updateReadStatus() }

        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    static func toggleReadUnread(container: NSPersistentContainer, items: [Item]) {
        if items.unread.isEmpty == true {
            clearHistory(container: container, items: items)
        } else {
            logHistory(container: container, items: items.unread)
        }
    }

    static func logHistory(container: NSPersistentContainer, items: [Item]) {
        let itemObjectIDs = items.map { $0.objectID }
        
        let context = container.newBackgroundContext()
        context.performAndWait {
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                let history = History.create(in: context)
                history.link = item.link
                history.visited = .now
                
                item.read = true
                item.trends.forEach { $0.updateReadStatus() }
            }

            do {
                try context.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func clearHistory(container: NSPersistentContainer, items: [Item]) {
        let itemObjectIDs = items.map { $0.objectID }
        
        let context = container.newBackgroundContext()
        context.performAndWait {
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }

                item.read = false
                item.trends.forEach { $0.updateReadStatus() }
                
                for history in item.history {
                    context.delete(history)
                }
            }

            do {
                try context.save()
                WidgetCenter.shared.reloadAllTimelines()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
