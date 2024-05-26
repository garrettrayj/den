//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import BackgroundTasks
import CoreData
import OSLog
import SwiftUI

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    @Environment(\.scenePhase) private var phase

    let dataController = DataController.shared
    
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(downloadManager)
                .environmentObject(networkMonitor)
                .environmentObject(refreshManager)
        }
        .handlesExternalEvents(matching: ["*"])
        .commands { AppCommands(networkMonitor: networkMonitor, refreshManager: refreshManager) }
        .defaultSize(CGSize(width: 1280, height: 800))
        #if os(iOS)
        .onChange(of: phase) {
            switch phase {
            case .background: 
                Task {
                    await scheduleMaintenance()
                    scheduleRefresh()
                }
            default: break
            }
        }
        .backgroundTask(.appRefresh("net.devsci.den.maintenance")) {
            Logger.main.debug("Performing background maintenance task...")
            await MaintenanceTask().execute()
            await scheduleMaintenance()
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            Logger.main.debug("Performing background refresh task...")
            await refreshManager.refresh()
            await scheduleRefresh()
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsSheet()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(refreshManager)
                .frame(width: 440)
                .frame(minHeight: 560)
        }
        .windowToolbarStyle(.expanded)
        #endif
    }
    
    init() {
        setupImageHandling()
    }

    private func setupImageHandling() {
        // SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 1024
        
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")
    }
    
    #if os(iOS)
    func scheduleMaintenance() async {
        if await BGTaskScheduler.shared.pendingTaskRequests().map({
            $0.identifier
        }).contains("net.devsci.den.maintenance") {
            Logger.main.info("Maintenance task is already scheduled")
            return
        }

        #if DEBUG
        let earliestBeginDate = Date().addingTimeInterval(1)
        #else
        let earliestBeginDate = Date().addingTimeInterval(60 * 60 * 48)
        #endif
        
        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.maintenance")
        request.requiresExternalPower = false
        request.requiresNetworkConnectivity = true
        request.earliestBeginDate = earliestBeginDate

        do {
            try BGTaskScheduler.shared.submit(request)

            Logger.main.info("""
            Maintenance task scheduled with earliest begin date of \
            \(earliestBeginDate.formatted())
            """)
        } catch {
            Logger.main.debug("""
            Scheduling maintenance task failed: \(error.localizedDescription)
            """)
        }
    }
    
    func scheduleRefresh() {
        let interval = UserDefaults.standard.integer(forKey: "RefreshInterval")
        guard interval > 0 else {
            Logger.main.debug("Background refresh is disabled. Scheduling skipped.")
            return
        }
        
        #if DEBUG
        let earliestBeginDate = Date().addingTimeInterval(1)
        #else
        let earliestBeginDate = Date().addingTimeInterval(TimeInterval(interval))
        #endif
        
        let request = BGAppRefreshTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = earliestBeginDate

        do {
            try BGTaskScheduler.shared.submit(request)

            Logger.main.info("""
            Refresh task scheduled with earliest begin date of \
            \(earliestBeginDate.formatted())
            """)
        } catch {
            Logger.main.debug("Scheduling refresh task failed: \(error.localizedDescription)")
        }
    }
    #endif
}
