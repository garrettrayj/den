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

    let persistenceController = PersistenceController.shared
    
    @State private var downloadManager = DownloadManager()
    @State private var networkMonitor = NetworkMonitor()
    @State private var refreshManager = RefreshManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(downloadManager)
                .environment(networkMonitor)
                .environment(refreshManager)
        }
        .defaultAppStorage(.group)
        .handlesExternalEvents(matching: ["*"])
        .commands { AppCommands(networkMonitor: networkMonitor, refreshManager: refreshManager) }
        .defaultSize(CGSize(width: 1280, height: 800))
        #if os(iOS)
        .onChange(of: phase) {
            switch phase {
            case .background: 
                scheduleMaintenance()
                scheduleRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("net.devsci.den.maintenance")) { _ in
            Logger.main.debug("Performing background maintenance task...")
            await MaintenanceTask().execute()
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) { _ in
            Logger.main.debug("Performing background refresh task...")
            await refreshManager.refresh()
            await scheduleRefresh()
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsSheet()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(refreshManager)
                .frame(width: 440)
                .frame(minHeight: 560)
        }
        .windowToolbarStyle(.expanded)
        .defaultAppStorage(.group)
        #endif
    }
    
    init() {
        setupImageHandling()
    }

    private func setupImageHandling() {
        SDImageCache.shared.config.maxMemoryCost = 1024 * 1024 * 1024
        
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
    func scheduleMaintenance() {
        if let maintained = UserDefaults.group.value(forKey: "Maintained") as? Double {
            let nextMaintenance = Date(timeIntervalSince1970: maintained) + 3 * 24 * 60 * 60
            if nextMaintenance > .now {
                Logger.main.info("""
                Next maintenance task will be scheduled after \
                \(nextMaintenance.formatted(), privacy: .public)
                """)

                return
            }
        }
        
        let request = BGProcessingTaskRequest(identifier: "net.devsci.den.maintenance")
        
        #if DEBUG
        let earliestBeginDate = Date().addingTimeInterval(1)
        #else
        let earliestBeginDate = Date().addingTimeInterval(60 * 60)
        #endif
        
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
        let interval = UserDefaults.group.value(forKey: "RefreshInterval") as? Int ?? 10800
        
        guard interval > 0 else {
            Logger.main.debug("Background refresh is disabled. Scheduling skipped.")
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: "net.devsci.den.refresh")
        let earliestBeginDate = Date().addingTimeInterval(TimeInterval(interval))
        request.earliestBeginDate = earliestBeginDate

        do {
            try BGTaskScheduler.shared.submit(request)

            Logger.main.info("""
            Refresh task scheduled with earliest begin date of \
            \(earliestBeginDate.formatted())
            """)
        } catch {
            Logger.main.debug("""
            Scheduling refresh task failed: \(error.localizedDescription)
            """)
        }
    }
    #endif
}
