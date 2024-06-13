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

/*
struct AppCommands: Commands {
    @Environment(\.openURL) private var openURL

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
}
*/
