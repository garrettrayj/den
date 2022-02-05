//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import SwiftUI

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

    var persistenceManager: PersistenceManager

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
        .onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .background:
                    cacheManager.performBackgroundCleanup()
                case .inactive:
                    break
                case .active:
                    break
                @unknown default:
                    break
                }
            }
    }

    init() {
        FileManager.default.initAppDirectories()
        persistenceManager = PersistenceManager()

        let crashManager = CrashManager()
        let cacheManager = CacheManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager
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
        let refreshManager = RefreshManager(
            persistentContainer: persistenceManager.container,
            crashManager: crashManager
        )
        let subscriptionManager = SubscriptionManager()
        let themeManager = ThemeManager()

        // StateObject managers
        _cacheManager = StateObject(wrappedValue: cacheManager)
        _crashManager = StateObject(wrappedValue: crashManager)
        _linkManager = StateObject(wrappedValue: linkManager)
        _profileManager = StateObject(wrappedValue: profileManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _subscriptionManager = StateObject(wrappedValue: subscriptionManager)
        _themeManager = StateObject(wrappedValue: themeManager)
    }
}
