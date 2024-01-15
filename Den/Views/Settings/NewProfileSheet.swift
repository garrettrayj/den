//
//  NewProfileSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NewProfileSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var color: AccentColor?

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Profile name placeholder.")
                    ) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                    .accessibilityIdentifier("ProfileName")
                } header: {
                    Text("Name", comment: "New profile sheet section header.")
                }

                Section {
                    AccentColorSelector(selection: $color)
                } header: {
                    Text("Customization", comment: "New profile sheet section header.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(Text("New Profile", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let profile = Profile.create(in: viewContext)
                        profile.wrappedName = name
                        profile.tintOption = color
                        profile.objectWillChange.send()
                        
                        do {
                            try viewContext.save()
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
        .frame(minWidth: 360, minHeight: 320)
    }
}
