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
import SDWebImageWebPCoder
import SDWebImageSVGCoder

@main
struct DenApp: App {
    @Environment(\.openURL) private var openURL

    @State private var refreshing = false
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingNewFeedSheet = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false
    
    @StateObject private var networkMonitor = NetworkMonitor()
    
    @AppStorage("CurrentProfileID") private var currentProfileID: String?

    let defaultSize = CGSize(width: 1280, height: 800)
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        #if os(macOS)
        Window(Text("Den", comment: "Window title."), id: "main") {
            rootView
        }
        .handlesExternalEvents(matching: ["*"])
        .commands { commands }
        .defaultSize(defaultSize)
        
        Settings {
            MacSettings()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
        #else
        WindowGroup {
            rootView
        }
        .handlesExternalEvents(matching: ["*"])
        .commands { commands }
        .defaultSize(defaultSize)
        #endif
    }
    
    @CommandsBuilder
    private var commands: some Commands {
        ToolbarCommands()
        SidebarCommands()
        InspectorCommands()
        CommandGroup(after: .newItem) {
            NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                .disabled(currentProfileID == nil)
            NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                .disabled(currentProfileID == nil)
            NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                .disabled(currentProfileID == nil)
        }
        CommandGroup(replacing: .importExport) {
            ImportButton(showingImporter: $showingImporter)
                .disabled(currentProfileID == nil)
            ExportButton(showingExporter: $showingExporter)
                .disabled(currentProfileID == nil)
        }
        CommandGroup(after: .toolbar) {
            RefreshButton()
                .disabled(currentProfileID == nil || refreshing || !networkMonitor.isConnected)
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
    
    @ViewBuilder
    private var rootView: some View {
        RootView(
            currentProfileID: $currentProfileID,
            refreshing: $refreshing,
            showingExporter: $showingExporter,
            showingImporter: $showingImporter,
            showingNewFeedSheet: $showingNewFeedSheet,
            showingNewPageSheet: $showingNewPageSheet,
            showingNewTagSheet: $showingNewTagSheet
        )
        .environment(\.managedObjectContext, persistenceController.container.viewContext)
        .environmentObject(networkMonitor)
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
        
        // Limit memory cache size
        SDImageCache.shared.config.maxMemoryCost = 200 * 1024 * 1024 // 200MB memory
    }
}
