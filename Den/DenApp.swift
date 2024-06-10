//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import BackgroundTasks
import SwiftData
import OSLog
import SwiftUI

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    #endif
    
    @Environment(\.scenePhase) private var scenePhase

    @State var container = DataController.shared.container
    
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(downloadManager)
                .environmentObject(networkMonitor)
                .environmentObject(refreshManager)
        }
        .modelContainer(container)
        .handlesExternalEvents(matching: ["*"])
        .commands { AppCommands(networkMonitor: networkMonitor, refreshManager: refreshManager) }
        .defaultSize(CGSize(width: 1280, height: 800))
        #if os(iOS)
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .background:
                Task { await scheduleRefresh() }
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
                .environmentObject(refreshManager)
                .frame(width: 440)
                .frame(minHeight: 560)
        }
        .modelContainer(container)
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
    func scheduleRefresh() async {
        let interval = UserDefaults.standard.integer(forKey: "RefreshInterval")
        guard interval > 0 else {
            Logger.main.debug("Background refresh is disabled. Scheduling skipped.")
            return
        }
        
        if await !BGTaskScheduler.shared.pendingTaskRequests().isEmpty {
            Logger.main.debug("Pending background refresh task already exists.")
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
