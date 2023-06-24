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

    @AppStorage("BackgroundRefreshEnabled") var backgroundRefreshEnabled: Bool = false
    @AppStorage("AppProfileID") var appProfileID: String?
    @AppStorage("LastCleanup") var lastCleanup: Double?
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system

    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    @State private var activeProfile: Profile?
    @State private var detailPanel: DetailPanel?

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                appProfileID: $appProfileID,
                activeProfile: $activeProfile,
                userColorScheme: $userColorScheme,
                detailPanel: $detailPanel
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(networkMonitor)
            .environmentObject(refreshManager)
            .preferredColorScheme(userColorScheme.colorScheme)
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                NewFeedButton()
                NewPageButton(activeProfile: $activeProfile)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
            CommandGroup(after: .sidebar) {
                Divider()
                RefreshButton(activeProfile: $activeProfile)
                    .environmentObject(refreshManager)
            }
            CommandGroup(replacing: .importExport) {
                ImportButton(activeProfile: $activeProfile)
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                ExportButton(activeProfile: $activeProfile)
            }
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        #else
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            await handleRefresh()
        }
        .backgroundTask(.appRefresh("net.devsci.den.cleanup")) {
            await handleCleanup()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                if backgroundRefreshEnabled {
                    scheduleRefresh()
                }
                scheduleCleanup()
            default: break
            }
        }
        #endif
        
        #if os(macOS)
        Settings {
            if let profile = activeProfile {
                SettingsTabs(
                    profile: profile,
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    useSystemBrowser: $useSystemBrowser,
                    userColorScheme: $userColorScheme,
                    detailPanel: $detailPanel
                )
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(userColorScheme.colorScheme)
            }
        }
        #endif
    }

    init() {
        setupImageHandling()
        resetUserDefaultsIfNeeded()
    }

    #if os(iOS)
    private func scheduleRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = .now + 30 * 60

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("""
            Refresh task scheduled with earliest begin date: \
            \(request.earliestBeginDate?.formatted() ?? "NA")
            """)
        } catch {
            Logger.main.warning("Failed to schedule refresh task: \(error)")
        }
        // Break here to simulate background task
    }

    private func scheduleCleanup() {
        if
            let lastCleaned = lastCleanup,
            Date(timeIntervalSince1970: lastCleaned) + 7 * 24 * 60 * 60 > .now
        {
            return
        }

        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.cleanup")
        request.earliestBeginDate = .now + 30 * 60

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("""
            Cleanup task scheduled with earliest begin date: \
            \(request.earliestBeginDate?.formatted() ?? "NA")
            """)
        } catch {
            Logger.main.warning("Failed to schedule cleanup task: \(error)")
        }
        // Break here to simulate background task
    }

    private func handleRefresh() {
        guard let profile = activeProfile else {
            return
        }
        Logger.main.info("Performing background refresh for profile: \(profile.wrappedName)")
        refreshManager.refresh(profile: profile)
    }

    private func handleCleanup() {
        let queue = OperationQueue()
        queue.addOperations([HistoryCleanupOperation(), DataCleanupOperation()], waitUntilFinished: true)
        lastCleanup = Date.now.timeIntervalSince1970
    }
    #endif

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

    private func resetUserDefaultsIfNeeded() {
        if CommandLine.arguments.contains("-in-memory") {
            let domain = Bundle.main.bundleIdentifier!
            UserDefaults.standard.removePersistentDomain(forName: domain)
        }
    }
}
