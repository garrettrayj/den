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
        case pickFile, folderSelection, inProgress, error, complete
    }
    
    @Environment(\.managedObjectContext) var viewContext
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var workspace: Workspace
    @ObservedObject var viewModel: ViewModel
    
    var importDocumentPicker: ImportDocumentPicker
    
    init(workspace: Workspace) {
        self.workspace = workspace
        
        _viewModel = ObservedObject(initialValue: ViewModel())
        self.importDocumentPicker = ImportDocumentPicker(importViewModel: _viewModel.wrappedValue)
    }
    
    var body: some View {
        VStack {
            if self.viewModel.stage == .pickFile {
                pickFileStage
            } else if viewModel.stage == .folderSelection {
                folderSelectionStage
            } else if viewModel.stage == .inProgress {
                inProgressStage
            } else if viewModel.stage == .complete {
                completeState
            }
        }
        .modifier(FormWrapperModifier())
        .navigationBarTitle("Import")
    }
    
    var pickFileStage: some View {
        Form {
            Section {
                Button(action: pickFile) {
                    Text("Choose OPML file...")
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
                    .onAppear(perform: { self.viewModel.selectedFolders.insert(folder) })
                }
            }
            
            Section {
                Button(action: {
                    self.viewModel.importSelected(managedObjectContext: self.viewContext, workspace: self.workspace)
                }) {
                    Text("Import Feeds")
                }
                
                Button(action: self.viewModel.reset) {
                    Text("Cancel")
                }
            }
        }
    }
    
    var inProgressStage: some View {
        Text("Import in progress")
    }
    
    var errorStage: some View {
        Text("Import error")
    }
    
    var completeState: some View {
        Text("Import complete")
    }
    
    var selectionSectionHeader: some View {
        HStack {
            Text("SELECT FOLDERS")
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
    
    func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

extension ImportView {
    class ViewModel: ObservableObject {
        @Published var stage: ImportStage = .pickFile
        @Published var importProgress: Double = 0
        @Published var opmlFolders: Array<OPMLFolder> = []
        @Published var selectedFolders = Set<OPMLFolder>()
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
            self.selectedFolders = Set<OPMLFolder>()
            self.pickedURL = nil
        }
        
        func toggleFolder(_ folder: OPMLFolder) {
            if selectedFolders.contains(folder) {
                selectedFolders.remove(folder)
            } else {
                selectedFolders.insert(folder)
            }
        }
        
        func selectAll() {
            opmlFolders.forEach { folder in
                if !selectedFolders.contains(folder) {
                    selectedFolders.insert(folder)
                }
            }
        }
        
        func selectNone() {
            selectedFolders.removeAll()
        }
        
        func importSelected(managedObjectContext: NSManagedObjectContext, workspace: Workspace) {
            
            
            
            
            
            DispatchQueue.global(qos: .userInteractive).async {
                var feedsForUpdate: Array<Feed> = []
                self.selectedFolders.forEach { opmlFolder in
                    let page = Page.create(in: managedObjectContext, workspace: workspace)
                    page.name = opmlFolder.name

                    opmlFolder.feeds.forEach { opmlFeed in
                        let feed = Feed.create(in: managedObjectContext, page: page)
                        feed.title = opmlFeed.title
                        feed.url = opmlFeed.url
                        feedsForUpdate.append(feed)
                    }
                }
                
                //let feedUpdater = FeedUpdater(feeds: feedsForUpdate)
                //feedUpdater.start()
                
                DispatchQueue.main.async {                    
                    self.stage = .complete
                }
            }
        }
    }
}

struct ImportView_Previews: PreviewProvider {
    static var previews: some View {
        ImportView(workspace: Workspace())
    }
}
