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
            .onOpenURL { url in
                SubscriptionUtility.showSubscribe(for: url.absoluteString)
            }
            .modifier(URLDropTargetModifier())
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            await handleRefresh(background: true)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                Logger.main.debug("Scene phase: active")
                if appState.activeProfile == nil {
                    loadProfile()
                }
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
    
    init() {
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")

        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 256 // MB
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
    
    private func handleRefresh(background: Bool = false) async {
        guard !appState.refreshing, let profile = appState.activeProfile else { return }
        await RefreshUtility.refresh(container: container, profile: profile)
    }
    
    private func loadProfile() {
        appState.activeProfile = ProfileUtility.loadProfile(context: container.viewContext)
        WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
    }
}
