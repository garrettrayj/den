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

    var body: some View {
        TabView {
            Form {
                LookAndFeelSection()
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
    }
}
