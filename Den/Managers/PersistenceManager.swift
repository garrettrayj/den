//
//  PersistenceManager.swift
//  Den
//
//  Created by Garrett Johnson on 12/25/20.
//

import CoreData

final class PersistenceManager: ObservableObject {
    let container: NSPersistentCloudKitContainer

    init() {
        self.container = NSPersistentCloudKitContainer(name: "Den")

        guard let appSupportDirectory = FileManager.default.appSupportDirectory else {
            return
        }

        // Create a store description for a CloudKit-backed store
        let cloudStoreLocation = appSupportDirectory.appendingPathComponent("Den.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.net.devsci.den"
        )

        // Create a store description for a local store
        let localStoreLocation = appSupportDirectory.appendingPathComponent("Den-Local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"

        // Create container
        self.container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]

        // Load both stores
        self.container.loadPersistentStores { _, error in
            guard error == nil else {
                /*
                Typical reasons for an error here include:
                 
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection
                  when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                return
            }

            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.undoManager = nil
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }
    }
}
