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

    @State private var name: String = ""
    
    @FocusState private var textFieldFocus: Bool
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var tags: FetchedResults<Tag>

    var body: some View {
        NavigationStack {
            Form {
                TextField(
                    text: $name,
                    prompt: Text("Untitled", comment: "Tag name placeholder.")
                ) {
                    Label {
                        Text("Name", comment: "Text field label.")
                    } icon: {
                        Image(systemName: "character.cursor.ibeam")
                    }
                }
                .focused($textFieldFocus)
            }
            .formStyle(.grouped)
            .onAppear {
                textFieldFocus = true
            }
            .navigationTitle(Text("New Tag", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let newTag = Tag.create(
                            in: viewContext,
                            userOrder: tags.maxUserOrder + 1
                        )
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
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 116)
        #endif
    }
}
