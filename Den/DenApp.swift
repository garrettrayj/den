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
    
    let persistenceController: PersistenceController = PersistenceController.shared
    
    @StateObject var crashManager: CrashManager = CrashManager.shared
    @StateObject var refreshManager: RefreshManager = RefreshManager()
    @StateObject var cacheManager: CacheManager = CacheManager()
    @StateObject var importManager: ImportManager = ImportManager()
    @StateObject var searchManager: SearchManager = SearchManager()
    @StateObject var subscriptionManager: SubscriptionManager = SubscriptionManager()
    @StateObject var themeManager: ThemeManager = ThemeManager()
    @StateObject var safariManager: SafariManager = SafariManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(refreshManager)
                .environmentObject(cacheManager)
                .environmentObject(importManager)
                .environmentObject(searchManager)
                .environmentObject(subscriptionManager)
                .environmentObject(crashManager)
                .environmentObject(themeManager)
                .environmentObject(safariManager)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif
                    
                    safariManager.controller = window?.rootViewController
                    
                    themeManager.window = window
                    themeManager.applyUIStyle()                    
                }.onOpenURL { url in
                    subscriptionManager.subscribe(to: url)
                }
        }
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
