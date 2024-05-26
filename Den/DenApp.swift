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
    @Environment(\.scenePhase) private var scenePhase

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
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                scheduleRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) {
            Logger.main.debug("Performing background refresh task...")
            await refreshManager.refresh(inBackground: true)
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
    func scheduleRefresh() {
        let interval = UserDefaults.standard.integer(forKey: "RefreshInterval")
        guard interval > 0 else {
            Logger.main.debug("Background refresh is disabled. Scheduling skipped.")
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: "net.devsci.den.refresh")
        request.earliestBeginDate = Date().addingTimeInterval(TimeInterval(interval))

        do {
            try BGTaskScheduler.shared.submit(request)

            Logger.main.info("""
            Refresh task scheduled with earliest begin date of \
            \(request.earliestBeginDate!.formatted())
            """)
        } catch {
            Logger.main.debug("Scheduling refresh task failed: \(error.localizedDescription)")
        }
    }
    #endif
}
