//
//  Persistence.swift
//  Den
//
//  Created by Garrett Johnson on 12/26/22.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

struct PersistenceController {
    static let shared = PersistenceController(
        inMemory: CommandLine.arguments.contains("-in-memory"),
        disableCloud: CommandLine.arguments.contains("-disable-cloud")
    )

    let cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
        containerIdentifier: "iCloud.net.devsci.den"
    )

    let cloudStoreDescription: NSPersistentStoreDescription
    let cloudStoreURL: URL

    let localStoreDescription: NSPersistentStoreDescription
    let localStoreURL: URL

    let container: NSPersistentContainer

    init(inMemory: Bool = false, disableCloud: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "Den")

        if inMemory {
            cloudStoreURL = URL(fileURLWithPath: "/dev/null/Den.sqlite")
            localStoreURL = URL(fileURLWithPath: "/dev/null/Den-Local.sqlite")

            // Create Cloud store description without `cloudKitContainerOptions`
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.configuration = "Cloud"

            // Create local store description
            localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
            localStoreDescription.configuration = "Local"
        } else {
            guard let appSupportDirectory = FileManager.default.appSupportDirectory else {
                preconditionFailure("Storage directory not available")
            }
            cloudStoreURL = appSupportDirectory.appendingPathComponent("Den.sqlite")
            localStoreURL = appSupportDirectory.appendingPathComponent("Den-Local.sqlite")

            // Create CloudKit-backed store description for syncing profile data
            cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
            cloudStoreDescription.configuration = "Cloud"

            // Create local store description for content and high churn data
            localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
            localStoreDescription.configuration = "Local"
        }

        if disableCloud {
            cloudStoreDescription.cloudKitContainerOptions = nil
        } else {
            cloudStoreDescription.cloudKitContainerOptions = cloudKitContainerOptions
        }

        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]

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
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
