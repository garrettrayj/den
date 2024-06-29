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
    static func markItemRead(modelContext: ModelContext, item: Item) {
        guard item.read == false else { return }

        let history = History.create(in: modelContext)
        history.link = item.link
        history.visited = .now

        item.read = true
        item.trends?.forEach { $0.updateReadStatus() }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func markItemUnread(modelContext: ModelContext, item: Item) {
        guard item.read == true else { return }

        for history in item.history {
            modelContext.delete(history)
        }

        item.read = false
        item.trends?.forEach { $0.updateReadStatus() }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func toggleReadUnread(modelContext: ModelContext, items: [Item]) {
        if items.unread.isEmpty == true {
            clearHistory(modelContext: modelContext, items: items)
        } else {
            logHistory(modelContext: modelContext, items: items.unread)
        }
    }

    static func logHistory(modelContext: ModelContext, items: [Item]) {
        for item in items {
            let history = History.create(in: modelContext)
            history.link = item.link
            history.visited = .now
            
            item.read = true
            item.trends?.forEach { $0.updateReadStatus() }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func clearHistory(modelContext: ModelContext, items: [Item]) {
        for item in items {
            item.read = false
            item.trends?.forEach { $0.updateReadStatus() }
            
            for history in item.history {
                modelContext.delete(history)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
