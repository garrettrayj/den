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
                TextField(
                    text: $name,
                    prompt: Text("Untitled", comment: "Page name placeholder.")
                ) {
                    Label {
                        Text("Name")
                    } icon: {
                        Image(systemName: "character.cursor.ibeam")
                    }
                }

                Button {
                    showingIconPicker = true
                } label: {
                    Label {
                        HStack {
                            Text("Choose Icon", comment: "Button label.")
                            Spacer()
                            ButtonChevron()
                        }
                    } icon: {
                        Image(systemName: symbol)
                    }
                }
                .buttonStyle(.borderless)
                .navigationDestination(isPresented: $showingIconPicker) {
                    IconPicker(symbolID: $symbol)
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
                        Text("Create Page")
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
        .frame(minWidth: 360, minHeight: 480)
    }
}
