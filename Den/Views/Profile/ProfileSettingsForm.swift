//
//  ProfileSettingsForm.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettingsForm: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var profile: Profile

    var body: some View {
        Form {
            TextField(text: $profile.wrappedName, prompt: Text("Den", comment: "Text field prompt.")) {
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

            Section {
                ClearDataButton(profile: profile).buttonStyle(.borderless)
                DeleteProfileButton(profile: profile).buttonStyle(.borderless)
            }
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
