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
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var blocklist: Blocklist
    
    @State private var isRefreshing = false

    var body: some View {
        Form {
            Section {
                TextField(
                    text: $blocklist.wrappedName,
                    prompt: Text("Untitled", comment: "Default content filter name.")
                ) {
                    Text("Name", comment: "Text field label.")
                }
                .labelsHidden()
            } header: {
                Text("Name", comment: "Section header.")
            }

            Section {
                TextField(text: $blocklist.urlString) {
                    Text("URL", comment: "Text field label.")
                }
                .labelsHidden()
            } header: {
                Text("URL", comment: "Section header.")
            }

            Section {
                if let blocklistStatus = blocklist.blocklistStatus {
                    LabeledContent {
                        if let refreshed = blocklistStatus.refreshed {
                            Text(verbatim: "\(refreshed.formatted())")
                        } else {
                            Text("Unknown", comment: "Blocklist refreshed date status.")
                        }
                    } label: {
                        Text("Refreshed", comment: "Blocklist status label.")
                    }
                    LabeledContent {
                        Text("\(blocklistStatus.totalConvertedCount)")
                    } label: {
                        Text("Converted Rules", comment: "Blocklist status label.")
                    }
                    LabeledContent {
                        Text("\(blocklistStatus.errorsCount)")
                    } label: {
                        Text("Errors", comment: "Blocklist status label.")
                    }
                    LabeledContent {
                        if blocklistStatus.overLimit {
                            Text("Yes", comment: "Boolean label.")
                        } else {
                            Text("No", comment: "Boolean label.")
                        }
                    } label: {
                        Text("Over Limit", comment: "Blocklist status label.")
                    }
                } else {
                    Label {
                        Text("Not Available", comment: "Blocklist status.")
                    } icon: {
                        Image(systemName: "questionmark")
                    }
                }
            } header: {
                Text("Status", comment: "Section header.")
            }

            Section {
                Button {
                    isRefreshing = true
                    Task {
                        await BlocklistManager.refreshContentRulesList(
                            blocklist: blocklist,
                            context: viewContext
                        )
                        blocklist.objectWillChange.send()
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
                
                Button(role: .destructive) {
                    Task {
                        await BlocklistManager.removeContentRulesList(
                            identifier: blocklist.id?.uuidString
                        )
                        viewContext.delete(blocklist)
                        
                        do {
                            try viewContext.save()
                            dismiss()
                        } catch {
                            CrashUtility.handleCriticalError(error as NSError)
                        }
                    }
                } label: {
                    Label {
                        Text("Delete", comment: "Button label.")
                    } icon: {
                        Image(systemName: "trash").symbolRenderingMode(.multicolor)
                    }
                }
            } header: {
                Text("Management")
            }
        }
        .buttonStyle(.borderless)
        .formStyle(.grouped)
        .navigationTitle(blocklist.nameText)
    }
}
