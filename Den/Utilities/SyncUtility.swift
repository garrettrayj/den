//
//  SyncUtility.swift
//  Den
//
//  Created by Garrett Johnson on 11/12/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI
import OSLog

struct SyncUtility {
    static func markItemRead(container: NSPersistentContainer?, item: Item) async {
        guard item.read != true else { return }
        await logHistory(container: container, items: [item])
        
        DispatchQueue.main.async {
            NotificationCenter.default.postItemStatus(item: item)
            item.feedData?.feed?.objectWillChange.send()
        }
    }

    static func toggleReadUnread(container: NSPersistentContainer?, items: [Item]) async {
        var modItems: [Item]

        if items.unread().isEmpty == true {
            modItems = items.read()
            await clearHistory(container: container, items: modItems)
        } else {
            modItems = items.unread()
            await logHistory(container: container, items: modItems)
        }
        
        for item in modItems {
            DispatchQueue.main.async {
                NotificationCenter.default.postItemStatus(item: item)
            }
        }
    }

    static func logHistory(container: NSPersistentContainer?, items: [Item]) async {
        guard let profileObjectID = items.first?.feedData?.feed?.page?.profile?.objectID else { return }
        let itemObjectIDs = items.map { $0.objectID }
        
        await container?.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }
            
            for itemObjectID in itemObjectIDs {
                guard let item = context.object(with: itemObjectID) as? Item else { continue }
                item.read = true

                let history = History.create(in: context, profile: profile)
                history.link = item.link
                history.title = item.title
                history.visited = .now
            }
            
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }

    static func clearHistory(container: NSPersistentContainer?, items: [Item]) async {
        let itemObjectIDs = items.map { $0.objectID }

        await container?.performBackgroundTask { context in
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

    static func resetHistory(container: NSPersistentContainer?, profile: Profile) async {
        await container?.performBackgroundTask { context in
            guard let profile = context.object(with: profile.objectID) as? Profile else { return }
            
            for history in profile.historyArray {
                context.delete(history)
            }
            
            for item in profile.previewItems.read() {
                item.read = false
            }
            
            do {
                try context.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
