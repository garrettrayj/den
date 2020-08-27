//
//  ImportManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import Foundation
import CoreData

class ImportManager: ObservableObject {
    enum ImportStage {
        case pickFile, folderSelection, error, importing
    }
    
    @Published var stage: ImportStage = .pickFile
    @Published var importProgress: Double = 0
    @Published var opmlFolders: [OPMLFolder] = []
    @Published var selectedFolders: [OPMLFolder] = []
    @Published var pickedURL: URL?
    
    var documentPicker: ImportDocumentPicker!
    var allSelected: Bool { selectedFolders.count == opmlFolders.count }
    var noneSelected: Bool { selectedFolders.count == 0 }
    
    private var viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        self.documentPicker = ImportDocumentPicker(importManager: self)
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
    
    func importSelected(workspace: Workspace) {
        stage = .importing
        
        let foldersToImport = opmlFolders.filter { opmlFolder in
            self.selectedFolders.contains(opmlFolder)
        }
        
        self.importFolders(opmlFolders: foldersToImport, workspace: workspace)
    }
    
    func importFolders(opmlFolders: [OPMLFolder], workspace: Workspace) {
        opmlFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, workspace: workspace)
            page.name = opmlFolder.name
            
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page)
                feed.title = opmlFeed.title
                feed.url = opmlFeed.url
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            fatalError("Unable to save import context: \(error)")
        }
    }
}
