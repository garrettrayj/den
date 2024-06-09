//
//  NewBlocklistSheet.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewBlocklistSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name: String = ""
    @State private var urlString: String = ""
    @State private var isCreating = false

    var body: some View {
        NavigationStack {
            Form {
                NavigationLink {
                    BlocklistPresets(name: $name, urlString: $urlString)
                } label: {
                    Label {
                        Text("Select Preset…", comment: "Button label.")
                    } icon: {
                        Image(systemName: "filemenu.and.selection")
                    }
                }
                .accessibilityIdentifier("BlocklistPresets")

                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Default content filter name.")
                    ) {
                        Label {
                            Text("Name", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                    
                    TextField(
                        text: $urlString,
                        prompt: Text(
                            "https⁣://example.com/blocklist.json",
                            comment: "Blocklist URL field prompt."
                        )
                        // Prompt contains an invisible separator after "https" to prevent link coloring
                    ) {
                        Label {
                            Text("URL", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    #endif
                } footer: {
                    Text(
                        "Filter rules must be in content blocker JSON format.",
                        comment: "New blocklist guidance."
                    )
                }
            }
            .disabled(isCreating)
            .formStyle(.grouped)
            .navigationTitle(Text("New Blocklist", comment: "Navigation title."))
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        isCreating = true
                        Task {
                            await addBlocklist()
                        }
                    } label: {
                        Text("Save", comment: "Button Label.")
                    }
                    .disabled(isCreating)
                    .accessibilityIdentifier("AddBlocklist")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button Label.")
                    }
                    .disabled(isCreating)
                    .accessibilityIdentifier("Cancel")
                }
            }
            #if os(macOS)
            .frame(minWidth: 360, idealWidth: 460, minHeight: 420)
            #endif
        }
    }

    private func addBlocklist() async {
        guard let url = URL(string: urlString) else { return }

        let blocklist = Blocklist.create(in: modelContext)
        blocklist.name = name
        blocklist.url = url
        
        await BlocklistManager.refreshContentRulesList(blocklist: blocklist, context: modelContext)

        dismiss()
    }
}
