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
    @Environment(\.openURL) private var openURL
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
        .commands { commands }
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
        }
        #endif
        
        #if os(macOS)
        Settings {
            SettingsSheet()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .frame(minWidth: 440, minHeight: 600)
        }
        .windowToolbarStyle(.expanded)
        .defaultAppStorage(.group)
        #endif
    }
    
    @CommandsBuilder
    private var commands: some Commands {
        ToolbarCommands()
        SidebarCommands()
        InspectorCommands()
        CommandGroup(after: .toolbar) {
            RefreshButton()
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
            Button {
                if let url = Bundle.main.url(
                    forResource: "Acknowledgements",
                    withExtension: "html"
                ) {
                    #if os(macOS)
                    NSWorkspace.shared.open(url)
                    #else
                    UIApplication.shared.open(url)
                    #endif
                }
            } label: {
                Text("Acknowledgements", comment: "Button label.")
            }
        }
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
            Logger.main.debug("Skipping scheduling. Background refresh is disabled.")
            return
        }
        
        let request = BGAppRefreshTaskRequest(identifier: "net.devsci.den.refresh")
        
        let earliestBeginDate = Date().addingTimeInterval(TimeInterval(interval))
        request.earliestBeginDate = earliestBeginDate

        try? BGTaskScheduler.shared.submit(request)
        
        Logger.main.debug(
            "Background refresh scheduled with earliest begin date of \(earliestBeginDate.formatted())"
        )
    }
    #endif
}
