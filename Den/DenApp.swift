//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI
import BackgroundTasks

import SDWebImage
import SDWebImageWebPCoder
import SDWebImageSVGCoder

@main
struct DenApp: App {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.openURL) private var openURL

    @AppStorage("BackgroundRefreshEnabled") private var backgroundRefreshEnabled: Bool = false
    @AppStorage("FeedRefreshTimeout") private var feedRefreshTimeout: Int = 30
    @AppStorage("LastCleanup") private var lastCleanup: Double?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    @StateObject private var networkMonitor = NetworkMonitor()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                userColorScheme: $userColorScheme,
                feedRefreshTimeout: $feedRefreshTimeout
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(networkMonitor)
            .preferredColorScheme(userColorScheme.colorScheme)
            .task {
                performCleanup()
            }
        }
        .commands {
            ToolbarCommands()
            SidebarCommands()
            CommandGroup(replacing: .help) {
                Button {
                    openURL(URL(string: "https://den.io/help/")!)
                } label: {
                    Text("\(Bundle.main.name) Help", comment: "Button label.")
                }
                #if os(macOS)
                Divider()
                Button {
                    if let url = Bundle.main.url(
                        forResource: "Acknowledgements",
                        withExtension: "html"
                    ) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Acknowledgements", comment: "Button label.")
                }
                #endif
            }
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        #endif

        #if os(macOS)
        Settings {
            SettingsForm(
                feedRefreshTimeout: $feedRefreshTimeout,
                userColorScheme: $userColorScheme
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .preferredColorScheme(userColorScheme.colorScheme)
        }
        #endif
    }

    init() {
        setupImageHandling()
    }

    private func performCleanup() {
        if let lastCleaned = lastCleanup {
            let nextCleanup = Date(timeIntervalSince1970: lastCleaned) + 7 * 24 * 60 * 60
            if nextCleanup > .now {
                Logger.main.debug("Next cleanup after: \(nextCleanup.formatted(), privacy: .public)")
            }
            return
        }
        
        persistenceController.container.performBackgroundTask { context in
            guard let profiles = try? context.fetch(Profile.fetchRequest()) as [Profile] else { return }
            for profile in profiles {
                try? HistoryUtility.removeExpired(context: context, profile: profile)
            }
            
            try? CleanupUtility.purgeOrphans(context: context)
            
            try? context.save()
        }
        
        lastCleanup = Date.now.timeIntervalSince1970
    }

    private func setupImageHandling() {
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")
    }
}
