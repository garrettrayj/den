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

    var body: some View {
        NavigationStack {
            ZStack {
                if profile.managedObjectContext == nil || profile.isDeleted {
                    Label {
                        Text("Profile Deleted", comment: "Object removed message.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                    .labelStyle(NoticeLabelStyle())
                } else {
                    ProfileSettingsForm(profile: profile, currentProfileID: $currentProfileID)
                }
            }
            .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
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
            .frame(minWidth: 370, minHeight: 300)
        }
        .tint(profile.tintColor)
    }
}
