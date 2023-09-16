//
//  NewTagSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewTagSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            Form {
                TextField(
                    text: $name,
                    prompt: Text("Untitled", comment: "Tag name placeholder.")
                ) {
                    Label {
                        Text("Name")
                    } icon: {
                        Image(systemName: "character.cursor.ibeam")
                    }
                }
            }
            .formStyle(.grouped)
            .navigationTitle(Text("New Tag", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newTag = Tag.create(in: viewContext, profile: profile)
                        newTag.wrappedName = name
                        dismiss()
                    } label: {
                        Text("Create Tag")
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
        .frame(minWidth: 360, minHeight: 120)
    }
}
