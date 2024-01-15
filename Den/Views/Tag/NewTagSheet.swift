//
//  NewTagSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NewTagSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State private var name: String = ""
    
    @FocusState private var textFieldFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Tag name placeholder.")
                    ) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                    .focused($textFieldFocus)
                } header: {
                    Text("Name", comment: "New tag sheet section header.")
                }
            }
            .formStyle(.grouped)
            .onAppear {
                textFieldFocus = true
            }
            .navigationTitle(Text("New Tag", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newTag = Tag.create(in: viewContext, profile: profile)
                        newTag.wrappedName = name
                        dismiss()
                    } label: {
                        Text("Save", comment: "Button label.")
                    }
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
        .frame(minWidth: 360, minHeight: 148)
    }
}
