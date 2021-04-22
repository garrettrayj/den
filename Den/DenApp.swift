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
    
    @StateObject var persistenceManager: PersistenceManager
    @StateObject var crashManager: CrashManager
    @StateObject var refreshManager: RefreshManager
    @StateObject var cacheManager: CacheManager
    @StateObject var importManager: ImportManager
    @StateObject var searchManager: SearchManager
    @StateObject var subscriptionManager: SubscriptionManager
    @StateObject var themeManager: ThemeManager
    @StateObject var browserManager: BrowserManager
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .environmentObject(refreshManager)
                .environmentObject(cacheManager)
                .environmentObject(importManager)
                .environmentObject(searchManager)
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
        let crashManager = CrashManager()
        let persistenceManager = PersistenceManager(crashManager: crashManager)
        let refreshManager = RefreshManager(persistenceManager: persistenceManager, crashManager: crashManager)
        let cacheManager = CacheManager(persistenceManager: persistenceManager)
        let importManager = ImportManager(persistenceManager: persistenceManager, crashManager: crashManager)
        let searchManager = SearchManager(persistenceManager: persistenceManager, crashManager: crashManager)
        let subscriptionManager = SubscriptionManager()
        let themeManager = ThemeManager()
        let browserManager = BrowserManager(persistenceManager: persistenceManager, crashManager: crashManager)
    
        _crashManager = StateObject(wrappedValue: crashManager)
        _persistenceManager = StateObject(wrappedValue: persistenceManager)
        _refreshManager = StateObject(wrappedValue: refreshManager)
        _cacheManager = StateObject(wrappedValue: cacheManager)
        _importManager = StateObject(wrappedValue: importManager)
        _searchManager = StateObject(wrappedValue: searchManager)
        _subscriptionManager = StateObject(wrappedValue: subscriptionManager)
        _themeManager = StateObject(wrappedValue: themeManager)
        _browserManager = StateObject(wrappedValue: browserManager)
    }
}

/**
 Extend `View` to allow access to UIWindow hosting the application.
 Enables customizing the titlebar and dark/light mode style.
 */
extension View {
    fileprivate func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

/**
 Representable to perform a callback with the view context's window.
 */
fileprivate struct HostingWindowFinder: UIViewRepresentable {
    var callback: (UIWindow?) -> ()

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async { [weak view] in
            self.callback(view?.window)
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
