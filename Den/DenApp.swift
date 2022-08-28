//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import OSLog
import SwiftUI

import SDWebImageSwiftUI
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main

struct DenApp: App {
    /**
     Main application setup. In the past similar functionality was contained in `SceneDelegate`.
     */
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var syncManager: SyncManager
    @StateObject var refreshManager: RefreshManager

    @State private var activeProfile: Profile?

    var body: some Scene {
        WindowGroup {
            RootView(activeProfile: $activeProfile)
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(syncManager)
                .environmentObject(refreshManager)
                .onOpenURL { url in
                    SubscriptionManager.showSubscribe(for: url)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
                if activeProfile?.id == nil {
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = WindowFinder.current()?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                    }
                    #endif
                    ThemeManager.applyStyle()
                    activeProfile = ProfileManager.loadProfile(context: persistentContainer.viewContext)
                }
                syncManager.syncHistory()
            case .inactive:
                Logger.main.debug("Scene phase: inactive")
            case .background:
                Logger.main.debug("Scene phase: background")
                syncManager.cleanupData()
                syncManager.cleanupHistory()
            @unknown default:
                Logger.main.debug("Scene phase: unknown")
            }
        }
    }

    var persistentContainer: NSPersistentContainer = {
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
                CrashManager.handleCriticalError(error! as NSError)
                return
            }

            container.viewContext.automaticallyMergesChangesFromParent = true
            container.viewContext.undoManager = nil
            container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        }

        return container
    }()

    init() {
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)
        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")

        let refreshManager = RefreshManager(persistentContainer: persistentContainer)
        let syncManager = SyncManager(viewContext: persistentContainer.viewContext)

        // StateObject managers
        _syncManager = StateObject(wrappedValue: syncManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
    }
}
