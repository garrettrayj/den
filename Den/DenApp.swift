//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import OSLog
import SwiftUI

import SDWebImageSwiftUI
import SDWebImageSVGCoder

@main

struct DenApp: App {
    /**
     Main application setup. In the past similar functionality was contained in `SceneDelegate`.
     */
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @StateObject var cacheManager: CacheManager
    @StateObject var crashManager: CrashManager
    @StateObject var linkManager: LinkManager
    @StateObject var profileManager: ProfileManager
    @StateObject var refreshManager: RefreshManager
    @StateObject var subscriptionManager: SubscriptionManager
    @StateObject var themeManager: ThemeManager
    @StateObject var persistenceManager: PersistenceManager

    @AppStorage("dataRevision") var dataRevision = 0

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(cacheManager)
                .environmentObject(crashManager)
                .environmentObject(linkManager)
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

                    linkManager.window = window
                }
                .onOpenURL { url in
                    subscriptionManager.showSubscribe(for: url)
                }
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("app.phase.active")
            case .inactive:
                Logger.main.debug("app.phase.inactive")
            case .background:
                Logger.main.debug("app.phase.background")
                cacheManager.cleanup()
            @unknown default:
                Logger.main.debug("app.phase.unknown")
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
        let cacheManager = CacheManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager,
            refreshManager: refreshManager
        )
        let profileManager = ProfileManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager
        )
        let linkManager = LinkManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager,
            profileManager: profileManager
        )
        let subscriptionManager = SubscriptionManager()
        let themeManager = ThemeManager()

        // StateObject managers
        _persistenceManager = StateObject(wrappedValue: persistenceManager)
        _cacheManager = StateObject(wrappedValue: cacheManager)
        _crashManager = StateObject(wrappedValue: crashManager)
        _linkManager = StateObject(wrappedValue: linkManager)
        _profileManager = StateObject(wrappedValue: profileManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _subscriptionManager = StateObject(wrappedValue: subscriptionManager)
        _themeManager = StateObject(wrappedValue: themeManager)

        initImageHandling()

        persistenceManager.migrateItemLimits()
    }

    private func initImageHandling() {
        // Add WebP/SVG/PDF support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageAWebPCoder.shared)

        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")

        // Add default HTTP header
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")
    }
}
