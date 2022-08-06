//
//  HistoryUpdateOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/5/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class HistoryUpdateOperation: Operation {
    enum Action {
        case create
        case clear
    }

    private let profileObjectID: NSManagedObjectID
    private let itemObjectIDs: [NSManagedObjectID]
    private let persistentContainer: NSPersistentContainer
    private let action: Action

    init(
        persistentContainer: NSPersistentContainer,
        profileObjectID: NSManagedObjectID,
        itemObjectIDs: [NSManagedObjectID],
        action: Action
    ) {
        self.persistentContainer = persistentContainer
        self.itemObjectIDs = itemObjectIDs
        self.profileObjectID = profileObjectID
        self.action = action
        super.init()
    }

    override func main() {
        if isCancelled { return }

        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = false

        context.performAndWait {
            switch action {
            case .create:
                logHistory(context: context)
            case .clear:
                clearHistory(context: context)
            }

            do {
                try context.save()
            } catch {
                self.cancel()
            }
        }
    }

    private func logHistory(context: NSManagedObjectContext) {
        guard let profile = context.object(with: self.profileObjectID) as? Profile else { return }

        for itemObjectID in itemObjectIDs {
            guard
                let item = context.object(with: itemObjectID) as? Item
            else { continue }

            let history = item.history?.first ?? History.create(in: context, profile: profile)
            history.link = item.link
            history.title = item.title
            history.visited = .now
        }
    }

    private func clearHistory(context: NSManagedObjectContext) {
        for itemObjectID in itemObjectIDs {
            guard
                let item = context.object(with: itemObjectID) as? Item
            else { continue }

            item.history?.forEach { history in
                context.delete(history)
            }
        }
    }
}
