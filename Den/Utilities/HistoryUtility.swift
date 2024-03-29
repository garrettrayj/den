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

struct HistoryUtility {
    static func markItemRead(
        context: NSManagedObjectContext,
        item: Item
    ) {
        guard 
            item.read == false,
            let profile = item.profile
        else { return }

        let history = History.create(in: context, profile: profile)
        history.link = item.link
        history.visited = .now

        item.read = true

        do {
            try context.save()
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

        do {
            try context.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    static func toggleReadUnread(items: [Item]) async {
        if items.unread().isEmpty == true {
            await clearHistory(items: items)
        } else {
            await logHistory(items: items.unread())
        }
    }

    static func logHistory(items: [Item]) async {
        guard let profileObjectID = items.first?.profile?.objectID else { return }
        let itemObjectIDs = items.map { $0.objectID }

        await PersistenceController.shared.container.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }

            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                let history = History.create(in: context, profile: profile)
                history.link = item.link
                history.visited = .now
                item.read = true
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func clearHistory(items: [Item]) async {
        let itemObjectIDs = items.map { $0.objectID }
        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                item.read = false
                for history in item.history {
                    context.delete(history)
                }
            }

            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
