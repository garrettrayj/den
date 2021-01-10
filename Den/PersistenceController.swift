//
//  Persistence.swift
//  Shared
//
//  Created by Garrett Johnson on 12/25/20.
//

import CoreData

struct PersistenceController {
    static var shared = PersistenceController()
    
    let container: NSPersistentCloudKitContainer
    
    init() {
        container = NSPersistentCloudKitContainer(name: "Den")
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.undoManager = nil
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                Typical reasons for an error here include:
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                CrashManager.shared.handleCriticalError(error)
            }
        })
    }
}
