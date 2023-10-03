//
//  NewPageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewPageSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State private var name: String = ""
    @State private var symbol: String = "folder"
    @State private var showingIconPicker: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Page name placeholder.")
                    ) {
                        Text("Name")
                    }
                } header: {
                    Text("Name", comment: "New page section header.")
                }

                IconSelectorButton(symbol: $symbol)
            }
            .formStyle(.grouped)
            .navigationTitle(Text("New Page", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        let page = Page.create(in: viewContext, profile: profile)
                        page.wrappedName = name
                        page.wrappedSymbol = symbol
                        dismiss()
                    } label: {
                        Text("Create Page", comment: "Button label.")
                    }
                    .accessibilityIdentifier("CreatePage")
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
        .frame(minWidth: 360, minHeight: 152)
    }
}
