//
//  SettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Double
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if profile.managedObjectContext == nil {
                    SplashNote(title: Text("Profile Deleted", comment: "Object removed message."))
                } else {
                    SettingsSheetForm(
                        activeProfile: $activeProfile,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        feedRefreshTimeout: $feedRefreshTimeout,
                        useSystemBrowser: $useSystemBrowser,
                        userColorScheme: $userColorScheme
                    )
                }
            }
            .toolbar {
                ToolbarItem {
                    Button {
                        dismiss()
                    } label: {
                        Label {
                            Text("Close", comment: "Button label.")
                        } icon: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("close-button")
                }
            }
        }
    }
}
