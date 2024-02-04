//
//  NewPageSheet.swift
//  Den
//
//  Created by Garrett Johnson on 9/15/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct NewPageSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @ObservedObject var profile: Profile

    @State private var name: String = ""
    @State private var symbol: String = "folder"
    @State private var showingIconSelector: Bool = false
    
    @FocusState private var textFieldFocus: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Page name placeholder.")
                    ) {
                        Text("Name", comment: "Text field label.")
                    }
                    .focused($textFieldFocus)
                }

                Section {
                    IconSelectorButton(showingIconSelector: $showingIconSelector, symbol: $symbol)
                        .sheet(isPresented: $showingIconSelector) {
                            IconSelector(selection: $symbol)
                        }
                }
            }
            .formStyle(.grouped)
            .onAppear {
                textFieldFocus = true
            }
            .navigationTitle(Text("New Page", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
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
        #if os(macOS)
        .frame(minWidth: 360, minHeight: 160)
        #endif
    }
}
