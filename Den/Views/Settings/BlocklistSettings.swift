//
//  BlocklistSettings.swift
//  Den
//
//  Created by Garrett Johnson on 10/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct BlocklistSettings: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var blocklist: Blocklist
    
    @State private var isRefreshing = false

    var body: some View {
        if blocklist.isDeleted || blocklist.managedObjectContext == nil {
            VStack {
                Spacer()
                ContentUnavailable {
                    Label {
                        Text("Blocklist Deleted")
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

                if let blocklistStatus = blocklist.blocklistStatus {
                    BlocklistStatusView(blocklistStatus: blocklistStatus)
                } else {
                    Label {
                        Text("Status Not Available", comment: "Blocklist status.")
                    } icon: {
                        Image(systemName: "questionmark")
                    }
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
                    
                    #if os(iOS)
                    DeleteBlocklistButton(selection: .constant(blocklist))
                        .symbolRenderingMode(.multicolor)
                    #endif
                }
            }
            .buttonStyle(.borderless)
            .formStyle(.grouped)
        }
    }
}
