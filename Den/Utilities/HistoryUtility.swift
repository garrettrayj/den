//
//  HistoryUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog
import SwiftUI
import WidgetKit

struct HistoryUtility {
    static func markItemRead(
        context: ModelContext,
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
        context: ModelContext,
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

    static func toggleReadUnread(items: [Item]) async {
        if items.unread.isEmpty == true {
            await clearHistory(items: items)
        } else {
            await logHistory(items: items.unread)
        }
    }

    static func logHistory(items: [Item]) async {
        let itemObjectIDs = items.map { $0.persistentModelID }
        let context = ModelContext(DataController.shared.container)

        for itemObjectID in itemObjectIDs {
            guard let item = context.model(for: itemObjectID) as? Item else { continue }
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

    static func clearHistory(items: [Item]) async {
        let itemObjectIDs = items.map { $0.persistentModelID }
        let context = ModelContext(DataController.shared.container)

        for itemObjectID in itemObjectIDs {
            guard let item = context.model(for: itemObjectID) as? Item else { continue }

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
