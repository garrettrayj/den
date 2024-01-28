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

    let profiles: [Profile]

    @Binding var currentProfileID: String?
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    var body: some View {
        NavigationStack {
            Form {
                LookAndFeelSection(
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
                ProfilesSection(profiles: profiles, currentProfileID: $currentProfileID)
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
