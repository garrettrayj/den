//
//  AnalyzeTask.swift
//  Den
//
//  Created by Garrett Johnson on 10/31/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData

struct AnalyzeTask {
    unowned let container: NSPersistentContainer
    unowned let profileObjectID: NSManagedObjectID

    func execute() async {
        await container.performBackgroundTask { context in
            TrendAnalysis.run(context: context, profileObjectID: profileObjectID)
        }
    }
}
