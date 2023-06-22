//
//  HistoryCleanupOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

final class HistoryCleanupOperation: Operation {
    override func main() {
        PersistenceController.shared.container.performBackgroundTask { context in
            let fetchRequest = Profile.fetchRequest()
            guard let profiles = try? context.fetch(fetchRequest) as [Profile] else { return }
            for profile in profiles {
                try? HistoryUtility.removeExpired(context: context, profile: profile)
            }
            try? context.save()
        }
    }
}
