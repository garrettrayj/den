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

@main
struct DenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase

    @AppStorage("BackgroundRefreshEnabled") var backgroundRefreshEnabled: Bool = false
    @AppStorage("AppProfileID") var appProfileID: String?
    @AppStorage("LastCleanup") var lastCleanup: Double?

    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    @State private var activeProfile: Profile?

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                appProfileID: $appProfileID,
                activeProfile: $activeProfile
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(networkMonitor)
            .environmentObject(refreshManager)
        }
        .commands {
            CommandGroup(after: .sidebar) {
                Divider()
                Button {
                    Task {
                        guard let profile = activeProfile else { return }
                        await refreshManager.refresh(profile: profile)
                    }
                } label: {
                    Text("Refresh", comment: "Menu bar button label")
                }
                .keyboardShortcut("r", modifiers: [.command])
            }
            CommandGroup(after: .importExport) {
                Button {
                    SubscriptionUtility.showSubscribe()
                } label: {
                    Text("Add Feed", comment: "Menu bar button label")
                }
                .keyboardShortcut("d", modifiers: [.command])
            }
        }
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
    }

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
}
