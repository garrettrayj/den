//
//  ProfileSettingsSheet.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var feedRefreshTimeout: Int
    @Binding var useSystemBrowser: Bool
    @Binding var userColorScheme: UserColorScheme

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if profile.managedObjectContext == nil {
                    SplashNote(title: Text("Profile Deleted", comment: "Object removed message."))
                } else {
                    ProfileSettingsForm(
                        profile: profile,
                        currentProfileID: $currentProfileID,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        feedRefreshTimeout: $feedRefreshTimeout,
                        useSystemBrowser: $useSystemBrowser,
                        userColorScheme: $userColorScheme
                    )
                }
            }
            .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        Task {
                            viewContext.rollback()
                            dismiss()
                        }
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Save")
                }
            }
            .frame(maxWidth: 360, minHeight: 280)
        }
        .tint(profile.tintColor)
    }
}
