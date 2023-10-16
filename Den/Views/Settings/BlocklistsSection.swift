//
//  BlocklistsSection.swift
//  Den
//
//  Created by Garrett Johnson on 10/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BlocklistsSection: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var blocklists: FetchedResults<Blocklist>

    @State private var showingNewBlocklist = false

    var body: some View {
        Section {
            if blocklists.isEmpty {
                Text("No Blocklists")
            } else {
                ForEach(blocklists) { blocklist in
                    HStack {
                        VStack(alignment: .leading) {
                            blocklist.nameText
                            if let url = blocklist.url {
                                Text(url.absoluteString).font(.caption)
                            }
                        }
                        Spacer()
                        Button(role: .destructive) {
                            viewContext.delete(blocklist)
                            do {
                                try viewContext.save()
                            } catch {
                                CrashUtility.handleCriticalError(error as NSError)
                            }
                        } label: {
                            Label {
                                Text("Delete", comment: "Button label.")
                            } icon: {
                                Image(systemName: "trash").symbolRenderingMode(.multicolor)
                            }
                        }
                        .labelStyle(.iconOnly)
                        .buttonStyle(.borderless)
                    }
                }
                .onDelete(perform: delete)
            }
            
            Button {
                showingNewBlocklist = true
            } label: {
                Label {
                    Text("Add Blocklist")
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .buttonStyle(.borderless)
        } header: {
            Text("Blocklists", comment: "Section header.")
        }
        .sheet(isPresented: $showingNewBlocklist) {
            NewBlocklist()
        }
    }

    private func delete(indices: IndexSet) {
        indices.forEach {
            let blocklist = blocklists[$0]
            viewContext.delete(blocklist)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }
}
