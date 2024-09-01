//
//  SettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 10/15/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                GeneralSection()
                AppearanceSection()
                BlocklistsSection()
                ResetSection()
                #if os(iOS)
                AboutSection()
                #endif
                
                NavigationLink {
                    DebuggingTools()
                } label: {
                    Label {
                        Text("Advanced", comment: "Button label.")
                    } icon: {
                        Image(systemName: "gearshape.2")
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
    }
}
