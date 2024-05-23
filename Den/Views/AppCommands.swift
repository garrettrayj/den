//
//  AppCommands.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AppCommands: Commands {
    @Environment(\.openURL) private var openURL

    let dataController: DataController
    let networkMonitor: NetworkMonitor
    let refreshManager: RefreshManager
    
    var body: some Commands {
        ToolbarCommands()
        SidebarCommands()
        InspectorCommands()
        CommandGroup(after: .toolbar) {
            RefreshButton()
                .environment(networkMonitor)
                .environment(refreshManager)
                .environment(dataController)
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
}
