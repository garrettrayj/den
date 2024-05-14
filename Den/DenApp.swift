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
    
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .defaultAppStorage(.group)
        .handlesExternalEvents(matching: ["*"])
        .commands { AppCommands() }
        .defaultSize(CGSize(width: 1280, height: 800))
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(downloadManager)
        .environmentObject(networkMonitor)
        .environmentObject(refreshManager)
        #if os(iOS)
        .onChange(of: phase) {
            switch phase {
            case .background: scheduleAppRefresh()
            default: break
            }
        }
        .backgroundTask(.appRefresh("net.devsci.den.refresh")) { _ in
            Logger.main.debug("Performing background refresh task...")
            await refreshManager.refresh()
            await scheduleAppRefresh()
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsSheet()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(refreshManager)
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
    func scheduleAppRefresh() {
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
            Background app refresh task scheduled with earliest begin date of \
            \(earliestBeginDate.formatted())
            """)
        } catch {
            Logger.main.debug("""
            Scheduling background app refresh task failed: \(error.localizedDescription)
            """)
        }
    }
    #endif
}
