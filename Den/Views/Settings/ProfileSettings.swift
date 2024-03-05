//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ProfileSettings: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    var body: some View {
        if profile.isDeleted || profile.managedObjectContext == nil {
            VStack {
                Spacer()
                ContentUnavailable {
                    Label {
                        Text("Profile Deleted", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                Spacer()
            }
        } else {
            Form {
                Section {
                    TextField(
                        text: $profile.wrappedName,
                        prompt: Text("Untitled", comment: "Profile name text field prompt.")
                    ) {
                        Label {
                            Text("Name", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                }

                Section {
                    AccentColorSelector(selection: $profile.tintOption)
                }
                
                Section {
                    ClearProfileHistoryButton(profile: profile)
                    DeleteProfileButton(profile: profile)
                }
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
            .onDisappear {
                guard !profile.isDeleted else { return }
                
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
}
