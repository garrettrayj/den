//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImportView: View {
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
        .navigationBarTitleDisplayMode(.inline)
    }

    private var pickFileStage: some View {
        VStack(alignment: .center) {
            Button(action: importViewModel.pickFile) {
                Text("Select OPML File")
            }.buttonStyle(AccentButtonStyle())
        }
        .modifier(SimpleMessageModifier())
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
                                }.padding(.vertical, 4)

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
                    .onAppear {
                        self.importViewModel.selectedFolders.append(folder)
                    }
                }
            }

            VStack(alignment: .center) {
                Button(action: importFeeds) {
                    Label("Import Subscriptions", systemImage: "arrow.down.doc")
                }
                .buttonStyle(AccentButtonStyle())
                .frame(alignment: .center)
                .disabled(!(importViewModel.selectedFolders.count > 0))
            }.frame(maxWidth: .infinity).listRowBackground(Color(UIColor.systemGroupedBackground))
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
        }.buttonStyle(ActionButtonStyle())
    }

    private func importFeeds() {
        self.importViewModel.importSelected()
    }

    private func cancel() {
        self.importViewModel.reset()
    }
}
