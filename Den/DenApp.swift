//
//  TestMultiplatformAppApp.swift
//  Shared
//
//  Created by Garrett Johnson on 12/25/20.
//

import SwiftUI

@main
struct DenApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        let refreshManager = RefreshManager(persistentContainer: persistenceController.container)
        let cacheManager = CacheManager(persistentContainer: persistenceController.container)
        let importManager = ImportManager(viewContext: persistenceController.container.viewContext)
        let searchManager = SearchManager(moc: persistenceController.container.viewContext)
        let subscriptionManager = SubscriptionManager()
        
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
