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
    enum ImportStage {
        case pickFile, folderSelection, error, importing
    }
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject var workspace: Workspace
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var updateManager: UpdateManager
    
    var importDocumentPicker: ImportDocumentPicker
    
    init(workspace: Workspace, viewModel: ViewModel, updateManager: UpdateManager) {
        self.workspace = workspace
        self.viewModel = viewModel
        self.updateManager = updateManager
        self.importDocumentPicker = ImportDocumentPicker(importViewModel: _viewModel.wrappedValue)
    }
    
    var body: some View {
        Group {
            if self.viewModel.stage == .pickFile {
                pickFileStage
            } else if self.viewModel.stage == .folderSelection {
                folderSelectionStage
            } else if self.viewModel.stage == .importing {
                if updateManager.updating {
                    inProgressStage
                } else {
                    completeStage
                }
            }
        }
        .onDisappear { self.viewModel.reset() }
        .modifier(FormWrapperModifier())
        .navigationBarTitle("Import OPML", displayMode: .inline)
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
                ForEach(viewModel.opmlFolders, id: \.name) { folder in
                    Button(action: { self.viewModel.toggleFolder(folder) }) {
                        HStack {
                            if self.viewModel.selectedFolders.contains(folder) {
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
                        self.viewModel.selectedFolders.append(folder)
                    }
                }
            }
            
            Section {
                Button(action: {
                    self.importSelected()
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
            Text("Fetching feeds...").font(.title)
            StandaloneProgressBarView(updateManager: updateManager).frame(maxWidth: 256, maxHeight: 8)
        }
    }
    
    var errorStage: some View {
        Text("Import Error").font(.title)
    }
    
    var completeStage: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle").resizable().scaledToFit().foregroundColor(.green).frame(width: 48, height: 48)
            Text("Finished").font(.title)
            Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
                Text("Back to Settings").fontWeight(.medium)
            }.buttonStyle(BorderedButtonStyle())
        }
    }
    
    var selectionSectionHeader: some View {
        HStack {
            Text("SELECT PAGES")
            Spacer()
            Button(action: viewModel.selectAll) {
                Text("ALL")
            }.disabled(viewModel.allSelected)
            Text("/")
            Button(action: viewModel.selectNone) {
                Text("NONE")
            }.disabled(viewModel.noneSelected)
        }
    }
    
    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too, so we do it this way instead of in a UIViewControllerRepresentable
     */
    func pickFile() {
        let viewController = UIApplication.shared.windows[0].rootViewController!
        let controller = self.importDocumentPicker.viewController
        viewController.present(controller, animated: true)
    }
    
    func importSelected() {
        self.viewModel.opmlFolders.forEach { opmlFolder in
            if self.viewModel.selectedFolders.contains(opmlFolder) == false {
                return
            }
            
            let page = Page.create(in: self.viewContext, workspace: self.workspace)
            page.name = opmlFolder.name
            
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page)
                feed.title = opmlFeed.title
                feed.url = opmlFeed.url
            }
        }
        
        do {
            try self.viewContext.save()
        } catch {
            fatalError("Failure saving context after import: \(error)")
        }
        
        
        self.updateManager.update()
        self.viewModel.stage = .importing
    }
}

extension ImportView {
    class ViewModel: ObservableObject {
        @Published var stage: ImportStage = .pickFile
        @Published var importProgress: Double = 0
        @Published var opmlFolders: [OPMLFolder] = []
        @Published var selectedFolders: [OPMLFolder] = []
        @Published var pickedURL: URL?
        
        var allSelected: Bool {
            selectedFolders.count == opmlFolders.count
        }
        
        var noneSelected: Bool {
            selectedFolders.count == 0
        }
        
        func reset() {
            self.stage = .pickFile
            self.importProgress = 0
            self.opmlFolders = []
            self.selectedFolders = []
            self.pickedURL = nil
        }
        
        func toggleFolder(_ folder: OPMLFolder) {
            if selectedFolders.contains(folder) {
                selectedFolders.removeAll { $0 == folder }
            } else {
                selectedFolders.append(folder)
            }
        }
        
        func selectAll() {
            opmlFolders.forEach { folder in
                if !selectedFolders.contains(folder) {
                    selectedFolders.append(folder)
                }
            }
        }
        
        func selectNone() {
            selectedFolders.removeAll()
        }
        
        
    }
}
