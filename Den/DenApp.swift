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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var crashManager: CrashManager
    @StateObject var syncManager: SyncManager
    @StateObject var profileManager: ProfileManager
    @StateObject var refreshManager: RefreshManager
    @StateObject var subscriptionManager: SubscriptionManager
    @StateObject var themeManager: ThemeManager
    @StateObject var persistenceManager: PersistenceManager

    @AppStorage("dataRevision") var dataRevision = 0

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(crashManager)
                .environmentObject(syncManager)
                .environmentObject(profileManager)
                .environmentObject(refreshManager)
                .environmentObject(subscriptionManager)
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
                    subscriptionManager.showSubscribe(for: url)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
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

    init() {
        FileManager.default.cleanupAppDirectories()

        var dbStorageType: StorageType = .persistent
        if CommandLine.arguments.contains("--reset") {
            dbStorageType = .inMemory
        }

        let crashManager = CrashManager()
        let persistenceManager = PersistenceManager(
            crashManager: crashManager,
            storageType: dbStorageType
        )
        let refreshManager = RefreshManager(
            persistentContainer: persistenceManager.container,
            crashManager: crashManager
        )
        let profileManager = ProfileManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager
        )
        let syncManager = SyncManager(
            persistentContainer: persistenceManager.container,
            crashManager: crashManager,
            profileManager: profileManager
        )
        let subscriptionManager = SubscriptionManager()
        let themeManager = ThemeManager()

        // StateObject managers
        _persistenceManager = StateObject(wrappedValue: persistenceManager)
        _crashManager = StateObject(wrappedValue: crashManager)
        _syncManager = StateObject(wrappedValue: syncManager)
        _profileManager = StateObject(wrappedValue: profileManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _subscriptionManager = StateObject(wrappedValue: subscriptionManager)
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
