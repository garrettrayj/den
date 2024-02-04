//
//  SettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var currentProfileID: String?
    
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                LookAndFeelSection(
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
                ProfilesSection(currentProfileID: $currentProfileID)
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
                        Text("Close", comment: "Button label.")
                    }
                }
            }
        }
        .frame(minWidth: 360, minHeight: 480)
    }
}
