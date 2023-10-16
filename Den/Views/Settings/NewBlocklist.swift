//
//  NewBlocklist.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewBlocklist: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @State private var name: String = ""
    @State private var urlString: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(
                        text: $name,
                        prompt: Text("Untitled", comment: "Default content filter name.")
                    ) {
                        Text("Name", comment: "Text field label.")
                    }
                    .labelsHidden()
                } header: {
                    Text("Name", comment: "Section header.")
                }

                Section {
                    TextField(text: $urlString) {
                        Text("URL", comment: "Text field label.")
                    }
                    .labelsHidden()
                } header: {
                    Text("URL", comment: "Section header.")
                }
            }
            .formStyle(.grouped)
            .navigationTitle(Text("New Blocklist", comment: "Navigation title."))
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        addBlocklist()
                    } label: {
                        Text("Add Blocklist", comment: "Button Label")
                    }
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Cancel", comment: "Button Label")
                    }
                }

                ToolbarItem {
                    Menu {
                        ForEach(BlocklistPreset.allCases, id: \.self) { blocklistPreset in
                            Button {
                                name = blocklistPreset.name
                                urlString = blocklistPreset.url.absoluteString
                            } label: {
                                Text(blocklistPreset.name)
                            }
                        }
                    } label: {
                        Text("Presets", comment: "Button label.")
                    }
                    .menuStyle(.button)
                }
            }
            .frame(minWidth: 360, minHeight: 200)
        }
    }

    private func addBlocklist() {
        guard let url = URL(string: urlString) else { return }

        var blocklist = Blocklist.create(in: viewContext)
        blocklist.name = name
        blocklist.url = url

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }

        dismiss()
    }
}
