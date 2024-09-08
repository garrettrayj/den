//
//  HistoryUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI
import WidgetKit

struct HistoryUtility {
    static func markItemRead(context: NSManagedObjectContext, item: Item) {
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

    static func markItemUnread(context: NSManagedObjectContext, item: Item) {
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

    static func toggleRead(items: any Collection<Item>, context: NSManagedObjectContext) {
        if items.unread.isEmpty == true {
            clearHistory(items: items, context: context)
        } else {
            logHistory(items: items.unread, context: context)
        }
    }

    static func logHistory(items: any Collection<Item>, context: NSManagedObjectContext) {
        var affectedTrends = Set<Trend>()
        
        for item in items {
            let history = History.create(in: context)
            history.link = item.link
            history.visited = .now
            item.read = true
            affectedTrends.formUnion(item.trends)
        }
        
        for trend in affectedTrends {
            trend.updateReadStatus()
        }

        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    static func clearHistory(items: any Collection<Item>, context: NSManagedObjectContext) {
        var affectedTrends = Set<Trend>()
        
        for item in items {
            for history in item.history {
                context.delete(history)
            }
            item.read = false
            affectedTrends.formUnion(item.trends)
        }
        
        for trend in affectedTrends {
            trend.updateReadStatus()
        }

        do {
            try context.save()
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
