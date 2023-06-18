//
//  SettingsSheetProfileDetail.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SettingsSheetProfileDetail: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @ObservedObject var profile: Profile
    
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    
    var body: some View {
        Form {
            Section {
                TextField(text: $profile.wrappedName, prompt: profile.nameText) {
                    Text("Name", comment: "Text field label.")
                }
                .onChange(of: profile.wrappedName) { _ in
                    if viewContext.hasChanges {
                        do {
                            try viewContext.save()
                        } catch let error {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                }
            } header: {
                Text("Name", comment: "Profile settings section header.")
            }
            
            Section {
                TintPicker(tintSelection: $profile.tintOption)
                    .onChange(of: profile.tint) { _ in
                        if viewContext.hasChanges {
                            do {
                                try viewContext.save()
                            } catch let error {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        }
                    }
            }
            
            DeleteProfileButton(profile: profile, callback: { dismiss() })
                .disabled(profile == activeProfile)
        }
        .formStyle(.grouped)
        .navigationTitle(Text("Profile Settings", comment: "Navigation title."))
        .toolbar {
            #if os(iOS)
            ToolbarItem {
                Button {
                    DispatchQueue.main.async {
                        appProfileID = profile.id?.uuidString
                        activeProfile = profile
                        profile.objectWillChange.send()
                    }
                    dismiss()
                } label: {
                    Label {
                        Text("Switch", comment: "Button label.")
                    } icon: {
                        Image(systemName: "arrow.left.arrow.right")
                    }
                }
                .labelStyle(.titleAndIcon)
                .buttonStyle(.borderless)
                .disabled(profile == activeProfile)
                .accessibilityIdentifier("switch-profile-button")
            }
            #endif
        }
    }
}
