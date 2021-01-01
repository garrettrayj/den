//
//  TestMultiplatformAppApp.swift
//  Shared
//
//  Created by Garrett Johnson on 12/25/20.
//

import SwiftUI

@main
struct DenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    private let persistenceController = PersistenceController.shared
    private let refreshManager = RefreshManager(persistentContainer: PersistenceController.shared.container)
    private let cacheManager = CacheManager(persistentContainer: PersistenceController.shared.container)
    private let importManager = ImportManager(viewContext: PersistenceController.shared.container.viewContext)
    private let searchManager = SearchManager(moc: PersistenceController.shared.container.viewContext)
    private let subscriptionManager = SubscriptionManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(refreshManager)
                .environmentObject(cacheManager)
                .environmentObject(importManager)
                .environmentObject(searchManager)
                .environmentObject(subscriptionManager)
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
}

extension View {
    fileprivate func withHostingWindow(_ callback: @escaping (UIWindow?) -> Void) -> some View {
        self.background(HostingWindowFinder(callback: callback))
    }
}

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
