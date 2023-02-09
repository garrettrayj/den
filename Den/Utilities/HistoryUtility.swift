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
    static func markItemRead(item: Item) async {
        guard item.read != true else { return }
        await logHistory(items: [item])

        DispatchQueue.main.async {
            item.feedData?.feed?.page?.objectWillChange.send()
        }
    }

    static func toggleReadUnread(items: [Item]) async {
        var modItems: [Item]

        if items.unread().isEmpty == true {
            modItems = items.read()
            await clearHistory(items: modItems)
        } else {
            modItems = items.unread()
            await logHistory(items: modItems)
        }
    }

    static func logHistory(items: [Item]) async {
        guard let profileObjectID = items.first?.feedData?.feed?.page?.profile?.objectID else { return }
        let itemObjectIDs = items.map { $0.objectID }

        let container = PersistenceController.shared.container

        await container.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }

            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                item.read = true

                let history = History.create(in: context, profile: profile)
                history.link = item.link
                history.visited = .now
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

    static func cleanupHistory(context: NSManagedObjectContext) {
        do {
            var itemsRemoved: Int = 0
            let profiles = try context.fetch(Profile.fetchRequest()) as [Profile]
            try profiles.forEach { profile in
                if profile.historyRetention == 0 { return }
                let historyRetentionStart = Date() - Double(profile.historyRetention) * 24 * 60 * 60
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "History")
                fetchRequest.predicate = NSPredicate(
                    format: "%K < %@",
                    #keyPath(History.visited),
                    historyRetentionStart as NSDate
                )
                fetchRequest.sortDescriptors = []

                let fetchResults = try context.fetch(fetchRequest) as? [History]
                fetchResults?.forEach { context.delete($0) }
                itemsRemoved += fetchResults?.count ?? 0
            }
            if context.hasChanges {
                try context.save()
            }
            Logger.main.info("History cleanup finished. \(itemsRemoved) entries removed")
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
