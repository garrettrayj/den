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

#if canImport(Sparkle)
import Sparkle
#endif

@main
struct DenApp: App {
    @Environment(\.openURL) private var openURL

    @StateObject private var networkMonitor = NetworkMonitor()

    let persistenceController = PersistenceController.shared

    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController
    #endif

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(networkMonitor)
        }
        .handlesExternalEvents(matching: ["*"])
        .commands {
            #if canImport(Sparkle)
            CommandGroup(after: .appInfo) {
                CheckForUpdatesView(updater: updaterController.updater)
            }
            #endif
            ToolbarCommands()
            SidebarCommands()
            InspectorCommands()
            CommandGroup(replacing: .help) {
                Button {
                    openURL(URL(string: "https://den.io/help/")!)
                } label: {
                    Text("\(Bundle.main.name) Help", comment: "Button label.")
                }
                #if os(macOS)
                Divider()
                Button {
                    if let url = Bundle.main.url(
                        forResource: "Acknowledgements",
                        withExtension: "html"
                    ) {
                        NSWorkspace.shared.open(url)
                    }
                } label: {
                    Text("Acknowledgements", comment: "Button label.")
                }
                #endif
            }
        }
        #if os(macOS)
        .defaultSize(width: 1200, height: 800)
        #endif
    }

    init() {
        #if canImport(Sparkle)
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        #endif
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
