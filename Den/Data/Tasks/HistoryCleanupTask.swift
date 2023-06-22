//
//  HistoryCleanupTask.swift
//  Den
//
//  Created by Garrett Johnson on 6/21/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct HistoryCleanupTask {
    unowned let profileObjectID: NSManagedObjectID

    func execute() async {
        await PersistenceController.shared.container.performBackgroundTask { context in
            guard let profile = context.object(with: profileObjectID) as? Profile else { return }
            try? HistoryUtility.removeExpired(context: context, profile: profile)
            try? context.save()
        }
    }
}
