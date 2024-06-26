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
    static func markItemRead(context: ModelContext, item: Item) {
        guard item.read == false else { return }

        let history = History.create(in: context)
        history.link = item.link
        history.visited = .now

        item.read = true
        item.trends?.forEach { $0.updateReadStatus() }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func markItemUnread(context: ModelContext, item: Item) {
        guard item.read == true else { return }

        for history in item.history {
            context.delete(history)
        }

        item.read = false
        item.trends?.forEach { $0.updateReadStatus() }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func toggleReadUnread(context: ModelContext, items: [Item]) {
        if items.unread.isEmpty == true {
            clearHistory(context: context, items: items)
        } else {
            logHistory(context: context, items: items.unread)
        }
    }

    static func logHistory(context: ModelContext, items: [Item]) {
        for item in items {
            let history = History.create(in: context)
            history.link = item.link
            history.visited = .now
            
            item.read = true
            item.trends?.forEach { $0.updateReadStatus() }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }

    static func clearHistory(context: ModelContext, items: [Item]) {
        for item in items {
            item.read = false
            item.trends?.forEach { $0.updateReadStatus() }
            
            for history in item.history {
                context.delete(history)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()
    }
}
