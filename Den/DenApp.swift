//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import SwiftUI

@main
/**
 Main application setup. In the past similar functionality was contained in `SceneDelegate`.
 */
struct DenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject var mainViewModel: MainViewModel
    @StateObject var persistenceManager: PersistenceManager
    @StateObject var crashManager: CrashManager
    @StateObject var profileManager: ProfileManager
    @StateObject var refreshManager: RefreshManager
    @StateObject var cacheManager: CacheManager
    @StateObject var importManager: ImportManager
    @StateObject var subscriptionManager: SubscriptionManager
    @StateObject var themeManager: ThemeManager
    @StateObject var browserManager: LinkManager
    
    var body: some Scene {
        WindowGroup {
            ContentView(mainViewModel: mainViewModel)
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(profileManager)
                .environmentObject(refreshManager)
                .environmentObject(cacheManager)
                .environmentObject(importManager)
                .environmentObject(subscriptionManager)
                .environmentObject(crashManager)
                .environmentObject(themeManager)
                .environmentObject(browserManager)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif
                    
                    browserManager.controller = window?.rootViewController
                    
                    themeManager.window = window
                    themeManager.applyUIStyle()
                }.onOpenURL { url in
                    subscriptionManager.subscribe(to: url)
                }
            }.onChange(of: scenePhase) { newScenePhase in
                switch newScenePhase {
                case .background:
                    if refreshManager.refreshing == false {
                        cacheManager.performBackgroundCleanup()
                    }
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
        let mainViewModel = MainViewModel()
        
        let crashManager = CrashManager(mainViewModel: mainViewModel)
        let persistenceManager = PersistenceManager(crashManager: crashManager)
        let profileManager = ProfileManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager,
            mainViewModel: mainViewModel
        )
        let refreshManager = RefreshManager(
            persistentContainer: persistenceManager.container,
            crashManager: crashManager
        )
        let cacheManager = CacheManager(
            persistentContainer: persistenceManager.container,
            crashManager: crashManager
        )
        let importManager = ImportManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager,
            mainViewModel: mainViewModel
        )
        let subscriptionManager = SubscriptionManager(mainViewModel: mainViewModel)
        let themeManager = ThemeManager()
        let browserManager = LinkManager(
            viewContext: persistenceManager.container.viewContext,
            crashManager: crashManager,
            mainViewModel: mainViewModel
        )
        
        _mainViewModel = StateObject(wrappedValue: mainViewModel)
        _crashManager = StateObject(wrappedValue: crashManager)
        _persistenceManager = StateObject(wrappedValue: persistenceManager)
        _profileManager = StateObject(wrappedValue: profileManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _cacheManager = StateObject(wrappedValue: cacheManager)
        _importManager = StateObject(wrappedValue: importManager)
        _subscriptionManager = StateObject(wrappedValue: subscriptionManager)
        _themeManager = StateObject(wrappedValue: themeManager)
        _browserManager = StateObject(wrappedValue: browserManager)
        
        FileManager.default.initAppDirectories()
    }
}
