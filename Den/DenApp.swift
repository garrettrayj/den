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
    
    private let persistenceController = PersistenceController.shared
    
    // Setup environment objects
    private let crashManager: CrashManager
    private let refreshManager: RefreshManager
    private let cacheManager: CacheManager
    private let importManager: ImportManager
    private let searchManager: SearchManager
    private let subscriptionManager: SubscriptionManager
    
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
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif
                    
                    SafariPresenter.controller = window?.rootViewController
                    UserInterfaceStyle.shared.window = window
                    UserInterfaceStyle.shared.applyUIStyle()
                }.onOpenURL { url in
                    subscriptionManager.subscribe(to: url)
                }
        }
    }
    
    init() {
        crashManager = CrashManager()
        refreshManager = RefreshManager(
            persistentContainer: PersistenceController.shared.container,
            crashManager: crashManager
        )
        cacheManager = CacheManager(persistentContainer: PersistenceController.shared.container)
        importManager = ImportManager(viewContext: PersistenceController.shared.container.viewContext)
        searchManager = SearchManager(moc: PersistenceController.shared.container.viewContext)
        subscriptionManager = SubscriptionManager()
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
