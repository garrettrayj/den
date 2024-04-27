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

    var body: some View {
        NavigationStack {
            Form {
                LookAndFeelSection()
                BlocklistsSection()
                ResetSection()
                AboutSection()
            }
            .buttonStyle(.borderless)
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
