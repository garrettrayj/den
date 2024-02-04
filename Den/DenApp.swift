//
//  DenApp.swift
//
//  Created by Garrett Johnson on 12/25/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
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

    let defaultSize = CGSize(width: 1280, height: 800)
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .handlesExternalEvents(matching: ["*"])
        .commands { commands }
        .defaultSize(defaultSize)
        
        #if os(macOS)
        Settings {
            MacSettings()
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
        #endif
    }
    
    @CommandsBuilder
    private var commands: some Commands {
        ToolbarCommands()
        SidebarCommands()
        InspectorCommands()
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
        
        // Limit memory cache size
        SDImageCache.shared.config.maxMemoryCost = 200 * 1024 * 1024 // 200MB memory
    }
}
