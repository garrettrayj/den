//
//  NewPageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct NewPageSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State private var name: String = ""
    @State private var symbol: String = "folder"
    @State private var showingIconSelector: Bool = false

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
                    .labelsHidden()
                } header: {
                    Text("Name", comment: "New page sheet section header.")
                }

                Section {
                    IconSelectorButton(showingIconSelector: $showingIconSelector, symbol: $symbol)
                        .sheet(isPresented: $showingIconSelector) {
                            IconSelector(selection: $symbol)
                        }
                } header: {
                    Text("Icon", comment: "New page sheet section header.")
                }
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
                        Text("Save", comment: "Button label.")
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
        .frame(minWidth: 360, minHeight: 240)
    }
}
