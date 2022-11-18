//
//  CustomEnvironment.swift
//  Den
//
//  Created by Garrett Johnson on 10/7/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

private struct PersistentContainerKey: EnvironmentKey {
    static let defaultValue: NSPersistentContainer = {
        let container = NSPersistentCloudKitContainer(name: "Den")
        
        guard let appSupportDirectory = FileManager.default.appSupportDirectory else {
            preconditionFailure("Storage directory not available")
        }

        var cloudStoreLocation = appSupportDirectory.appendingPathComponent("Den.sqlite")
        var localStoreLocation = appSupportDirectory.appendingPathComponent("Den-Local.sqlite")

        if CommandLine.arguments.contains("--reset") {
            // Use in memory storage
            cloudStoreLocation = URL(fileURLWithPath: "/dev/null/1")
            localStoreLocation = URL(fileURLWithPath: "/dev/null/2")
        }

        // Create a store description for a CloudKit-backed store
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.net.devsci.den"
        )

        // Create a store description for a local store
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"

        // Create container
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]

        // Load both stores
        container.loadPersistentStores { _, error in
            guard error == nil else {
                /*
                Typical reasons for an error here include:
                 
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection
                  when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                CrashUtility.handleCriticalError(error! as NSError)
                return
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.undoManager = nil
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }

        return container
    }()
}

extension EnvironmentValues {
  var persistentContainer: NSPersistentContainer {
    get { self[PersistentContainerKey.self] }
    set { self[PersistentContainerKey.self] = newValue }
  }
}
