//
//  NewProfileSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct NewProfileSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var color: AccentColor?
    
    var callback: ((Profile) -> Void)?
    
    @FocusState private var textFieldFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Profile name text field prompt.")
                    ) {
                        Label {
                            Text("Name", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                    .focused($textFieldFocus)
                    .accessibilityIdentifier("ProfileName")
                }

                AccentColorSelector(selection: $color)
            }
            .onAppear {
                textFieldFocus = true
            }
            .formStyle(.grouped)
            .navigationTitle(Text("New Profile", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let profile = Profile.create(in: viewContext)
                        profile.wrappedName = name
                        profile.tintOption = color
                        profile.objectWillChange.send()
                        
                        do {
                            try viewContext.save()
                            callback?(profile)
                            dismiss()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
                    .accessibilityIdentifier("CreateProfile")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(role: .cancel) {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button label.")
                    }
                    .accessibilityIdentifier("Cancel")
                }
            }
        }
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 192)
        #endif
    }
}
