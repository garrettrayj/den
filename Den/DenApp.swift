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

    @StateObject var contentViewModel: ContentViewModel

    var persistenceManager: PersistenceManager
    var cacheManager: CacheManager

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: contentViewModel)
                .environment(\.managedObjectContext, persistenceManager.container.viewContext)
                .withHostingWindow { window in
                    #if targetEnvironment(macCatalyst)
                    if let titlebar = window?.windowScene?.titlebar {
                        titlebar.titleVisibility = .hidden
                        titlebar.toolbar = nil
                    }
                    #endif

                    contentViewModel.hostingWindow = window
                    contentViewModel.applyUIStyle()
                }
                .onOpenURL { url in
                    contentViewModel.showAddSubscription(to: url)
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

        let contentViewModel = ContentViewModel(persistenceManager: persistenceManager)
        _contentViewModel = StateObject(wrappedValue: contentViewModel)

        cacheManager = CacheManager(
            persistentContainer: persistenceManager.container,
            contentViewModel: contentViewModel
        )
    }
}
