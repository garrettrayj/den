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

#if os(iOS)
@preconcurrency import BackgroundTasks
#endif

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    #if os(iOS)
    @UIApplicationDelegateAdaptor var delegate: AppDelegate
    #endif
    
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase

    @StateObject private var dataController = DataController()
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(downloadManager)
                .environmentObject(networkMonitor)
                .environmentObject(refreshManager)
        }
        .handlesExternalEvents(matching: ["*"])
        .commands {
            ToolbarCommands()
            SidebarCommands()
            InspectorCommands()
            CommandGroup(after: .toolbar) {
                RefreshButton()
                    .environmentObject(dataController)
                    .environmentObject(networkMonitor)
                    .environmentObject(refreshManager)
            }
            CommandGroup(replacing: .help) {
                Button {
                    openURL(URL(string: "https://den.io/help/")!)
                } label: {
                    Text("Den Help", comment: "Button label.")
                }
                Divider()
                
                #if os(macOS)
                Button {
                    if let url = Bundle.main.url(
                        forResource: "Acknowledgements",
                        withExtension: "pdf"
                    ) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Acknowledgements", comment: "Button label.")
                }
                #endif
            }
        }
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
            await handleAppRefresh()
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsSheet()
                .environment(\.managedObjectContext, dataController.container.viewContext)
                .environmentObject(dataController)
                .environmentObject(refreshManager)
                .frame(width: 440)
                .frame(minHeight: 560)
        }
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
    private func handleAppRefresh() async {
        Logger.main.debug("Performing background refresh task...")
        await refreshManager.refresh(container: dataController.container, inBackground: true)
        await scheduleRefresh()
    }
    
    private func scheduleRefresh() async {
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
