//
//  HistorySyncOperation.swift
//  Den
//
//  Created by Garrett Johnson on 8/6/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog

final class HistorySyncOperation: Operation {
    let persistentContainer: NSPersistentContainer
    let profileObjectID: NSManagedObjectID

    init(
        persistentContainer: NSPersistentContainer,
        profileObjectID: NSManagedObjectID
    ) {
        self.persistentContainer = persistentContainer
        self.profileObjectID = profileObjectID
    }

    override func main() {
        if isCancelled { return }

        let context: NSManagedObjectContext = self.persistentContainer.newBackgroundContext()
        context.undoManager = nil
        context.automaticallyMergesChangesFromParent = true

        context.performAndWait {
            syncHistory(context: context)

            do {
                try context.save()
            } catch {
                self.cancel()
            }
        }
    }

    private func syncHistory(context: NSManagedObjectContext) {
        guard let items = try? context.fetch(Item.fetchRequest()) as [Item] else { return }

        for item in items {
            item.read = item.history?.isEmpty == false
        }
    }
}
