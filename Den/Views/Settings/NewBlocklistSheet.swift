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
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var urlString: String = ""
    @State private var isCreating = false
    @State private var blocklistSources: [BlocklistManifest.Item] = []

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Menu {
                        ForEach(blocklistSources) { blocklistSource in
                            Button {
                                name = blocklistSource.name
                                urlString = blocklistSource.convertedURL.absoluteString
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(blocklistSource.name).fontWeight(.semibold)
                                    Text(blocklistSource.description).font(.caption)
                                }
                            }
                        }
                    } label: {
                        Text("Presets", comment: "Menu label.")
                    }
                    .accessibilityIdentifier("BlocklistPresets")
                    .task {
                        blocklistSources = await BlocklistManifest.fetch()
                    }
                }
                
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Default content filter name.")
                    ) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                } header: {
                    Text("Name", comment: "New blocklist sheet section header.")
                }
                
                Section {
                    TextField(text: $urlString) {
                        Text("URL", comment: "Text field label.")
                    }
                    .labelsHidden()
                } header: {
                    Text("URL", comment: "New blocklist sheet section header.")
                } footer: {
                    Text("Filter rules must be in content blocker JSON format.").foregroundStyle(.secondary)
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
                        Text("Add Blocklist", comment: "Button Label")
                    }
                    .disabled(isCreating)
                    .accessibilityIdentifier("AddBlocklist")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button Label")
                    }
                    .disabled(isCreating)
                    .accessibilityIdentifier("Cancel")
                }
            }
            .frame(minWidth: 360, idealWidth: 460, minHeight: 300)
        }
    }

    private func addBlocklist() async {
        guard let url = URL(string: urlString) else { return }

        let blocklist = Blocklist.create(in: viewContext)
        blocklist.name = name
        blocklist.url = url
        
        await BlocklistManager.refreshContentRulesList(blocklist: blocklist, context: viewContext)

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }

        dismiss()
    }
}
