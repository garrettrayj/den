//
//  ProfileNotAvailableView.swift
//  Den
//
//  Created by Garrett Johnson on 2/22/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ProfileNotAvailableView: View {
    @Binding var showingSettings: Bool

    var body: some View {
        StatusBoxView(
            message: Text("Profile Not Available"),
            caption: Text("Select or create a profile in settings"),
            symbol: "hexagon"
        )
        .navigationTitle("")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showingSettings = true
                } label: {
                    Label("Settings", systemImage: "gear").labelStyle(.titleAndIcon)
                }
                .accessibilityIdentifier("start-settings-button")
            }
        }
    }
}
