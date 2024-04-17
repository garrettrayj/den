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

import SDWebImage
import SDWebImageSVGCoder
import SDWebImageWebPCoder

@main
struct DenApp: App {
    @Environment(\.openURL) private var openURL

    let persistenceController = PersistenceController.shared
    
    @StateObject private var downloadManager = DownloadManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var refreshManager = RefreshManager()
    
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system

    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(userColorScheme.colorScheme)
                .tint(accentColor?.color)
        }
        .handlesExternalEvents(matching: ["*"])
        .commands { commands }
        .defaultSize(CGSize(width: 1280, height: 800))
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(downloadManager)
        .environmentObject(networkMonitor)
        .environmentObject(refreshManager)
        
        #if os(macOS)
        Settings {
            MacSettings()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .preferredColorScheme(userColorScheme.colorScheme)
                .tint(accentColor?.color)
        }
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
        // Add additional image format support
        SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
        SDImageCodersManager.shared.addCoder(SDImageWebPCoder.shared)

        // Explicit list of accepted image types so servers may decide what to respond with
        let imageAcceptHeader: String  = ImageMIMEType.allCases.map({ mimeType in
            mimeType.rawValue
        }).joined(separator: ",")
        SDWebImageDownloader.shared.setValue(imageAcceptHeader, forHTTPHeaderField: "Accept")
    }
}
