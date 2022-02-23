//
//  MissingProfileView.swift
//  Den
//
//  Created by Garrett Johnson on 2/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct MissingProfileView: View {
    @Binding var showingSettings: Bool

    var body: some View {
        StatusBoxView(
            message: Text("Profile Missing"),
            caption: Text("Select another in settings")
        )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }
                .buttonStyle(ToolbarButtonStyle())
                .accessibilityIdentifier("start-settings-button")
            }
        }
    }
}
