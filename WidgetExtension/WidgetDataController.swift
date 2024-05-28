//
//  WidgetDataController.swift
//  Widget Extension
//
//  Created by Garrett Johnson on 5/22/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog

/// Simplified, read-only, version of data controller used in the application.
struct WidgetDataController {
    static func getContainer() -> NSPersistentContainer {
        let container = NSPersistentCloudKitContainer(name: "Den")
        
        guard let appGroupURL = AppGroup.den.containerURL?.appending(
            path: "Library/Application Support",
            directoryHint: .isDirectory
        ) else {
            preconditionFailure("Storage directory not available")
        }
        
        // Create CloudKit-backed store description for syncing profile data
        let cloudStoreURL = appGroupURL.appending(path: "Den.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreURL)
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(
            containerIdentifier: "iCloud.net.devsci.den"
        )
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.isReadOnly = true
        
        // Create local store description for content and high churn data
        let localStoreURL = appGroupURL.appending(path: "Den-Local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreURL)
        localStoreDescription.configuration = "Local"
        localStoreDescription.isReadOnly = true

        container.persistentStoreDescriptions = [cloudStoreDescription, localStoreDescription]
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
                Logger.widgets.error("Unable to load persistent stores.")
                return
            }
        }

        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        return container
    }
}
