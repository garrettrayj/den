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
    @StateObject var profileManager: ProfileManager
    @StateObject var refreshManager: RefreshManager
    @StateObject var themeManager: ThemeManager

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                .environmentObject(syncManager)
                .environmentObject(profileManager)
                .environmentObject(refreshManager)
                .environmentObject(themeManager)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                    }
                    #endif

                    themeManager.window = window
                    themeManager.applyStyle()

                    syncManager.window = window
                }
                .onOpenURL { url in
                    SubscriptionManager.showSubscribe(for: url)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
                profileManager.loadProfile()
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
        FileManager.default.cleanupAppDirectories()

        let refreshManager = RefreshManager(persistentContainer: persistentContainer)
        let profileManager = ProfileManager(viewContext: persistentContainer.viewContext)
        let syncManager = SyncManager(
            persistentContainer: persistentContainer,
            profileManager: profileManager
        )
        let themeManager = ThemeManager()

        // StateObject managers
        _syncManager = StateObject(wrappedValue: syncManager)
        _profileManager = StateObject(wrappedValue: profileManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _themeManager = StateObject(wrappedValue: themeManager)

        initImageHandling()
    }

    private func initImageHandling() {
        // Add WebP/SVG/PDF support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")

        // Add default HTTP header
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")
    }
}
