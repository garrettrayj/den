//
//  MacSettings.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct MacSettings: View {
    private enum Tabs: Hashable {
        case general, profiles, blocklists
    }
    
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        TabView {
            Form {
                LookAndFeelSection(
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
                ResetSection()
            }
            .tabItem {
                Label {
                    Text("General", comment: "Tab label.")
                } icon: {
                    Image(systemName: "gearshape")
                }
            }
            .tag(Tabs.general)
            
            ProfilesTab()
                .tabItem {
                    Label {
                        Text("Profiles", comment: "Tab label.")
                    } icon: {
                        Image(systemName: "person")
                    }
                }
                .tag(Tabs.profiles)

            BlocklistsTab()
                .tabItem {
                    Label {
                        Text("Blocklists", comment: "Tab label.")
                    } icon: {
                        Image(systemName: "square.slash")
                    }
                }
                .tag(Tabs.blocklists)
        }
        .listStyle(.sidebar)
        .formStyle(.grouped)
        .buttonStyle(.borderless)
        .frame(minWidth: 600, minHeight: 420)
        .preferredColorScheme(userColorScheme.colorScheme)
    }
}
