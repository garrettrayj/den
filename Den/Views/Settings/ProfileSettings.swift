//
//  ProfileSettings.swift
//  Den
//
//  Created by Garrett Johnson on 5/19/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
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
                    TextField(text: $profile.wrappedName, prompt: profile.nameText) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                } header: {
                    Text("Name", comment: "Profile settings section header.")
                }

                Section {
                    AccentColorSelector(selection: $profile.tintOption)
                        .onChange(of: profile.tint) {
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                } header: {
                    Text("Customization", comment: "Profile settings section header.")
                }

                ProfileHistorySection(profile: profile)
                
                #if os(iOS)
                Section {
                    DeleteProfileButton(selection: .constant(profile))
                        .symbolRenderingMode(.multicolor)
                } header: {
                    Text("Management", comment: "Profile settings section header.")
                }
                #endif
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
            .onDisappear {
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
