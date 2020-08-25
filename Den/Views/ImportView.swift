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
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @EnvironmentObject var refreshManager: RefreshManager
    @EnvironmentObject var importManager: ImportManager
    @ObservedObject var workspace: Workspace
    
    var body: some View {
        Group {
            if self.importManager.stage == .pickFile {
                pickFileStage
            } else if self.importManager.stage == .folderSelection {
                folderSelectionStage
            } else if self.importManager.stage == .importing {
                if refreshManager.isRefreshing(workspace) {
                    inProgressStage
                } else {
                    completeStage
                }
            }
        }
        .onDisappear { self.importManager.reset() }
        .frame(maxWidth: 980)
        .navigationBarTitle("Import", displayMode: .inline)
    }
    
    var pickFileStage: some View {
        Form {
            Section(header: Text("FILE SELECTION")) {
                Button(action: pickFile) {
                    Text("Choose file to import...")
                }
            }
        }
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
            
            Section {
                Button(action: {
                    self.importManager.importSelected(workspaceObjectID: self.workspace.objectID)
                    self.refreshManager.refresh(self.workspace)
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.down.on.square")
                        Text("Import")
                    }
                }
            }
        }
    }
    
    var inProgressStage: some View {
        VStack (spacing: 16) {
            ActivityRep()
            Text("Downloading").font(.title)
            StandaloneProgressBarView(refreshable: workspace).frame(maxWidth: 256, maxHeight: 8)
        }
    }
    
    var errorStage: some View {
        Text("Import Error").font(.title)
    }
    
    var completeStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle").resizable().scaledToFit().foregroundColor(.green).frame(width: 48, height: 48)
            Text("Import Finished").font(.title)
        }
    }
    
    var selectionSectionHeader: some View {
        HStack {
            Text("SELECT PAGES")
            Spacer()
            Button(action: importManager.selectAll) {
                Text("ALL")
            }.disabled(importManager.allSelected)
            Text("/")
            Button(action: importManager.selectNone) {
                Text("NONE")
            }.disabled(importManager.noneSelected)
        }
    }
    
    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too, so we do it this way instead of in a UIViewControllerRepresentable
     */
    func pickFile() {
        let viewController = UIApplication.shared.windows[0].rootViewController!
        let controller = self.importManager.documentPicker.viewController
        viewController.present(controller, animated: true)
    }
}
