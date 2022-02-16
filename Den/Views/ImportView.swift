//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
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
        .frame(maxWidth: .infinity)
        .onDisappear(perform: {
            importViewModel.reset()
        })
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Import")
    }

    private var pickFileStage: some View {
        VStack(spacing: 20) {
            Spacer()
            Button(action: importViewModel.pickFile) {
                Label("Select OPML File", systemImage: "filemenu.and.cursorarrow")
            }
            .buttonStyle(AccentButtonStyle())
            .accessibilityIdentifier("import-pick-file-button")
            Text("You will be able to choose pages to import in the next step")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 300)
        .padding()
    }

    private var folderSelectionStage: some View {
        Form {
            Section(header: selectionSectionHeader) {
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
                    .accessibilityIdentifier("import-toggle-folder-button")
                }
            }.modifier(SectionHeaderModifier())

            Section {
                Button(action: importFeeds) {
                    Label("Import Pages", systemImage: "arrow.down.doc")
                }
                .buttonStyle(AccentButtonStyle())
                .disabled(!(importViewModel.selectedFolders.count > 0))
                .accessibilityIdentifier("import-submit-button")
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
            Text("Select")
            Spacer()
            HStack {
                Button(action: importViewModel.selectAll) { Text("All") }
                    .disabled(importViewModel.allSelected)
                    .accessibilityIdentifier("import-select-all-button")
                Text("/").foregroundColor(.secondary)
                Button(action: importViewModel.selectNone) { Text("None") }
                    .disabled(importViewModel.noneSelected)
                    .accessibilityIdentifier("import-select-none-button")
            }
            .font(.system(size: 12))
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
