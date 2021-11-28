//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var importViewModel: ImportViewModel

    var body: some View {
        VStack {
            if self.importViewModel.stage == .pickFile {
                pickFileStage
            } else if self.importViewModel.stage == .folderSelection {
                folderSelectionStage
            } else if self.importViewModel.stage == .importing {
                completeStage
            }
        }
        .onDisappear(perform: {
            importViewModel.reset()
        })
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Import")
    }

    private var pickFileStage: some View {
        VStack(alignment: .center) {
            Button(action: importViewModel.pickFile) {
                Label("Select OPML file", systemImage: "filemenu.and.selection")
            }.buttonStyle(AccentButtonStyle())
        }
        .modifier(SimpleMessageModifier())
    }

    private var folderSelectionStage: some View {
        Form {
            Section(header: selectionSectionHeader.modifier(SectionHeaderModifier())) {
                ForEach(importViewModel.opmlFolders, id: \.name) { folder in
                    Button { self.importViewModel.toggleFolder(folder) } label: {
                        Label(
                            title: {
                                HStack {
                                    Text(folder.name).foregroundColor(.primary)
                                    Spacer()
                                    Text("\(folder.feeds.count) feeds").foregroundColor(.secondary)
                                }

                            },
                            icon: {
                                if self.importViewModel.selectedFolders.contains(folder) {
                                    Image(systemName: "checkmark.circle.fill")
                                } else {
                                    Image(systemName: "circle")
                                }
                            }
                        )
                    }
                    .modifier(FormRowModifier())
                    .onAppear {
                        self.importViewModel.selectedFolders.append(folder)
                    }
                }
            }

            Section {
                Button(action: importFeeds) {
                    Label("Import Feeds", systemImage: "arrow.down.doc")
                }
                .buttonStyle(AccentButtonStyle())
                .disabled(!(importViewModel.selectedFolders.count > 0))
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }

    private var errorStage: some View {
        Text("Error").font(.title)
    }

    private var completeStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text("Import Complete").font(.title)
            Text("Added \(importViewModel.feedsImported.count) feeds to \(importViewModel.pagesImported.count) pages")
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    private var selectionSectionHeader: some View {
        HStack {
            Text("Select Folders")
            Spacer()
            Button(action: importViewModel.selectAll) {
                Text("All")
            }.disabled(importViewModel.allSelected)
            Text("/")
            Button(action: importViewModel.selectNone) {
                Text("None")
            }.disabled(importViewModel.noneSelected)
        }
    }

    private func importFeeds() {
        self.importViewModel.importSelected()
        dismiss()
    }

    private func cancel() {
        self.importViewModel.reset()
    }
}
