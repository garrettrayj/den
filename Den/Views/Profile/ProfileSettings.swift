//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 1/7/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?

    var deleteCallback: () -> Void

    @State private var showingDeleteAlert: Bool = false

    var body: some View {
        Form {
            TextField(text: $profile.wrappedName, prompt: Text("Untitled", comment: "Text field prompt.")) {
                Label {
                    Text("Name", comment: "Text field label.")
                } icon: {
                    Image(systemName: "character.cursor.ibeam")
                }
            }

            TintPicker(tintSelection: $profile.tintOption)

            HistorySettingsSection(
                profile: profile,
                historyRentionDays: profile.wrappedHistoryRetention
            )

            #if os(iOS)
            Section {
                DeleteProfileButton(profile: profile) {
                    dismiss()
                }
                .disabled(activeProfile == profile)
            }
            #endif
        }
        .formStyle(.grouped)
        .onDisappear {
            if profile.isDeleted { return }
            if viewContext.hasChanges {
                do {
                    try viewContext.save()
                } catch let error {
                    CrashUtility.handleCriticalError(error as NSError)
                }
            }
        }
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    DispatchQueue.main.async {
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        profile.objectWillChange.send()
                        dismiss()
                    }
                } label: {
                    Label {
                        Text("Switch", comment: "Button label.")
                    } icon: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                .labelStyle(.titleAndIcon)

                .disabled(profile == activeProfile)
                .accessibilityIdentifier("switch-to-profile-button")
            }
            #endif
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom) {
            HStack {
                DeleteProfileButton(profile: profile, callback: deleteCallback)
                    .buttonStyle(.bordered)
                    .disabled(profile == activeProfile)

                Spacer()
                Button {
                    DispatchQueue.main.async {
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        profile.objectWillChange.send()
                    }
                } label: {
                    Label {
                        Text("Switch", comment: "Button label.")
                    } icon: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(profile == activeProfile)
                .accessibilityIdentifier("switch-profile-button")
            }
            .padding(12)
        }
        #endif
    }
}
