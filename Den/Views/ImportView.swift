//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct ImportView: View {
    @Environment(\.presentationMode) var presentation
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var importManager: ImportManager
    
    @ObservedObject var mainViewModel: MainViewModel
    
    var body: some View {
        Group {
            if self.importManager.stage == .pickFile {
                pickFileStage
            } else if self.importManager.stage == .folderSelection {
                folderSelectionStage
            } else if self.importManager.stage == .importing {
                completeStage
            }
        }
        .navigationTitle("Import")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    var pickFileStage: some View {
        VStack(alignment: .center) {
            Button(action: importManager.pickFile) {
                Text("Select OPML File")
            }.buttonStyle(ActionButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.all)
    }
    
    var folderSelectionStage: some View {
        Form {
            Section(header: selectionSectionHeader) {
                ForEach(importManager.opmlFolders, id: \.name) { folder in
                    Button(action: { self.importManager.toggleFolder(folder) }) {
                        HStack {
                            if self.importManager.selectedFolders.contains(folder) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                            Text(folder.name).foregroundColor(Color.primary)
                            Spacer()
                            Text("\(folder.feeds.count) feeds").font(.callout).foregroundColor(.secondary)
                        }
                    }
                    .onAppear {
                        self.importManager.selectedFolders.append(folder)
                    }
                }
            }
            
            VStack(alignment: .center) {
                Button(action: {
                    self.importManager.importSelected()
                }) {
                    HStack {
                        Image(systemName: "arrow.down.doc")
                        Text("Import Subscriptions").lineLimit(1)
                    }
                }.buttonStyle(ActionButtonStyle()).frame(alignment: .center)
            }.frame(maxWidth: .infinity).listRowBackground(Color(UIColor.systemGroupedBackground))
        }
        .toolbar() {
            ToolbarItem() {
                Button(action: cancel) {
                    Text("Cancel")
                }
            }
        }
    }
    
    var errorStage: some View {
        Text("Error").font(.title)
    }
    
    var completeStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 48)
            Text("Import Complete").font(.title)
            Text("Added \(importManager.feedsImported.count) feeds to \(importManager.pagesImported.count) pages")
                .foregroundColor(Color(.secondaryLabel))
        }
    }
    
    var selectionSectionHeader: some View {
        HStack {
            Text("Select Folders")
            Spacer()
            Button(action: importManager.selectAll) {
                Text("All")
            }.disabled(importManager.allSelected)
            Text("/")
            Button(action: importManager.selectNone) {
                Text("None")
            }.disabled(importManager.noneSelected)
        }
    }
    
    private func cancel() {
        self.importManager.reset()
    }
}
