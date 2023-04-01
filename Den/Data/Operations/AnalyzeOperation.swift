//
//  AnalyzeOperation.swift
//  Den
//
//  Created by Garrett Johnson on 4/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

final class AnalyzeOperation: Operation {
    let profileObjectID: NSManagedObjectID

    init(profileObjectID: NSManagedObjectID) {
        self.profileObjectID = profileObjectID
    }

    override func main() {
        PersistenceController.shared.container.performBackgroundTask { context in
            TrendAnalysis.run(context: context, profileObjectID: self.profileObjectID)
        }
    }
}
