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
                GeneralSection()
                BlocklistsSection()
                ResetSection()
                #if os(iOS)
                AboutSection()
                #endif
            }
            .formStyle(.grouped)
            .buttonStyle(.borderless)
            .navigationTitle(Text("Settings", comment: "Navigation title."))
            #if os(iOS)
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
            #endif
        }
    }
}
