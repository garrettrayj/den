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

    var body: some View {
        NavigationStack {
            Form {
                GeneralSection()
                BlocklistsSection()
                ResetSection()
                #if os(iOS)
                AboutSection()
                #endif
                
                NavigationLink {
                    DebuggingTools()
                } label: {
                    Label {
                        Text("Debugging Tools")
                    } icon: {
                        Image(systemName: "ladybug")
                    }
                }
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
        .preferredColorScheme(userColorScheme.colorScheme)
        .tint(accentColor?.color)
    }
}
