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

            ProfileColorPicker(selection: $profile.tintOption)

            HistorySettingsSection(
                profile: profile,
                historyRentionDays: profile.wrappedHistoryRetention
            )

            #if os(iOS)
            Section {
                DeleteProfileButton(profile: profile) {
                    dismiss()
                }
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
    }
}
