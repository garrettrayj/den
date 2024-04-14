//
//  MacSettings.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct MacSettings: View {
    private enum Tabs: Hashable {
        case general, blocklists
    }
    
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        TabView {
            Form {
                LookAndFeelSection(
                    accentColor: $accentColor,
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
                ResetSection()
            }
            .tabItem {
                Label {
                    Text("General", comment: "Settings tab label.")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
            .tag(Tabs.general)

            BlocklistsTab()
                .tabItem {
                    Label {
                        Text("Blocklists", comment: "Settings tab label.")
                    } icon: {
                        Image(systemName: "square.slash")
                    }
                }
                .tag(Tabs.blocklists)
        }
        .listStyle(.sidebar)
        .formStyle(.grouped)
        .buttonStyle(.borderless)
        .frame(width: 600, height: 380)
        .preferredColorScheme(userColorScheme.colorScheme)
        .tint(accentColor?.color)
    }
}
