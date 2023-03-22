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

    @StateObject var networkMonitor = NetworkMonitor()

    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView(
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                appProfileID: $appProfileID
            )
            .environment(\.managedObjectContext, persistenceController.container.viewContext)
            .environmentObject(networkMonitor)
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            await handleRefresh()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .background:
                if backgroundRefreshEnabled {
                    scheduleAppRefresh()
                }
            default: break
            }
        }
    }

    private func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = .now + 5 * 60
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false

        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("""
            Background refresh task scheduled with earliest begin date: \
            \(request.earliestBeginDate?.formatted() ?? "NA")
            """)
        } catch {
            Logger.main.warning("Failed to schedule background refresh task.")
        }
        // Break here to simulate background task
    }

    private func handleRefresh() async {
        guard let profiles = try? persistenceController.container.viewContext.fetch(
            Profile.fetchRequest()
        ) as? [Profile] else {
            return
        }

        for profile in profiles where profile.id?.uuidString == appProfileID {
            await RefreshUtility.refresh(profile: profile)
        }
    }
}
