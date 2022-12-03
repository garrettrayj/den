//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//

import CoreData
import OSLog
import SwiftUI
import BackgroundTasks

import SDWebImageSwiftUI
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.persistentContainer) private var container
    
    @StateObject private var appState = AppState()
    
    @AppStorage("AutoRefreshEnabled") var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") var autoRefreshCooldown: Int = 30
    @AppStorage("AutoRefreshDate") var autoRefreshDate: Double = 0.0
    @AppStorage("BackgroundRefreshEnabled") var backgroundRefreshEnabled: Bool = false
    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified
    
    var body: some Scene {
        WindowGroup {
            RootView(
                appState: appState,
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                uiStyle: $uiStyle
            )
            .preferredColorScheme(ColorScheme(uiStyle))
            .environment(\.managedObjectContext, container.viewContext)
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            await handleRefresh()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
                if autoRefreshEnabled && !appState.refreshing && (
                    autoRefreshDate == 0.0 ||
                    Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                ) {
                    Task {
                        await handleRefresh()
                    }
                    autoRefreshDate = Date.now.timeIntervalSinceReferenceDate
                }
            case .inactive:
                Logger.main.debug("Scene phase: inactive")
            case .background:
                Logger.main.debug("Scene phase: background")
                if backgroundRefreshEnabled {
                    scheduleAppRefresh()
                }
            @unknown default:
                Logger.main.debug("Scene phase: unknown")
            }
        }
    }
    
    private func scheduleAppRefresh() {
        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = .now + 10 * 60
        request.requiresNetworkConnectivity = true
        request.requiresExternalPower = false
        
        do {
            try BGTaskScheduler.shared.submit(request)
            Logger.main.info("""
            Background refresh task scheduled with earliest begin date \
            \(request.earliestBeginDate?.formatted() ?? "NA")
            """)
        } catch {
            Logger.main.warning("Background refresh not scheduled")
        }
        // Break here to simulate background task
    }
    
    private func handleRefresh() async {
        guard !appState.refreshing, let profile = appState.activeProfiles.first else { return }
        await RefreshUtility.refresh(container: container, profile: profile)
    }
}
