//
//  BlocklistSettings.swift
//  Den
//
//  Created by Garrett Johnson on 10/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlocklistSettings: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject private var dataController: DataController

    @ObservedObject var blocklist: Blocklist
    
    @State private var isRefreshing = false

    var body: some View {
        if blocklist.isDeleted || blocklist.managedObjectContext == nil {
            VStack {
                Spacer()
                ContentUnavailable {
                    Label {
                        Text("Blocklist Deleted", comment: "Content unavailable title.")
                    } icon: {
                        Image(systemName: "trash")
                    }
                }
                Spacer()
            }
        } else {
            Form {
                Section {
                    TextField(
                        text: $blocklist.wrappedName,
                        prompt: Text("Untitled", comment: "Default content filter name.")
                    ) {
                        Label {
                            Text("Name", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                    
                    TextField(
                        text: $blocklist.urlString,
                        // Prompt contains an invisible separator after "https" to prevent link coloring
                        prompt: Text(verbatim: "https⁣://example.com/blocklist.json")
                    ) {
                        Label {
                            Text("URL", comment: "Text field label.")
                        } icon: {
                            Image(systemName: "globe")
                        }
                    }
                }

                if let blocklistStatus = blocklist.blocklistStatus {
                    BlocklistStatusView(blocklistStatus: blocklistStatus)
                } else {
                    Label {
                        Text("Status Unknown", comment: "Blocklist status message.")
                    } icon: {
                        Image(systemName: "questionmark")
                    }
                }
                
                Section {
                    Button {
                        isRefreshing = true
                        Task {
                            await BlocklistManager.refreshContentRulesList(
                                container: dataController.container,
                                blocklistObjectID: blocklist.objectID
                            )
                            isRefreshing = false
                        }
                    } label: {
                        Label {
                            Text("Refresh", comment: "Button label.")
                        } icon: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                    .disabled(isRefreshing)
                    
                    DeleteBlocklistButton(blocklist: blocklist)
                }
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
            .onDisappear {
                guard !blocklist.isDeleted else { return }

                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        }
    }
}
