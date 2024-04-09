//
//  SettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                LookAndFeelSection(
                    accentColor: $accentColor,
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
                BlocklistsSection()
                ResetSection()
                AboutSection()
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
            .navigationTitle(Text("Settings", comment: "Navigation title."))
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", comment: "Button label.")
                        } icon: {
                            Image(systemName: "xmark")
                        }
                    }
                }
            }
        }
    }
}
