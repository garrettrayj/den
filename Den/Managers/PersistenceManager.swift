//
//  Persistence.swift
//  Shared
//
//  Created by Garrett Johnson on 12/25/20.
//

import CoreData

class PersistenceManager: ObservableObject {
    let container: NSPersistentCloudKitContainer
    
    private let crashManager: CrashManager
    
    init(crashManager: CrashManager) {
        self.crashManager = crashManager

        let applicationSupportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).last!
        
        // Create a store description for a CloudKit-backed store
        let cloudStoreLocation = applicationSupportDirectory.appendingPathExtension("Den.sqlite")
        let cloudStoreDescription = NSPersistentStoreDescription(url: cloudStoreLocation)
        cloudStoreDescription.configuration = "Cloud"
        cloudStoreDescription.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.net.devsci.den")
        
        // Create a store description for a local store
        let localStoreLocation = applicationSupportDirectory.appendingPathExtension("Den-Local.sqlite")
        let localStoreDescription = NSPersistentStoreDescription(url: localStoreLocation)
        localStoreDescription.configuration = "Local"
        
        // Create container
        container = NSPersistentCloudKitContainer(name: "Den")
        container.persistentStoreDescriptions = [
            cloudStoreDescription,
            localStoreDescription
        ]
        
        // Load both stores
        container.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                /*
                Typical reasons for an error here include:
                - The parent directory does not exist, cannot be created, or disallows writing.
                - The persistent store is not accessible, due to permissions or data protection when the device is locked.
                - The device is out of space.
                - The store could not be migrated to the current model version.
                */
                crashManager.handleCriticalError(error! as NSError)
                return
            }
            
            self.container.viewContext.automaticallyMergesChangesFromParent = true
            self.container.viewContext.undoManager = nil
        }
    }
}
