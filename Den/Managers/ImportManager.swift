//
//  ImportManager.swift
//  Den
//
//  Created by Garrett Johnson on 8/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI
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
    @Published var feedsImported: [Feed] = []
    @Published var pagesImported: [Page] = []
    
    var documentPicker: ImportDocumentPicker!
    var allSelected: Bool { selectedFolders.count == opmlFolders.count }
    var noneSelected: Bool { selectedFolders.count == 0 }

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var mainViewModel: MainViewModel
    
    init(persistenceManager: PersistenceManager, crashManager: CrashManager, mainViewModel: MainViewModel) {
        self.viewContext = persistenceManager.container.viewContext
        self.crashManager = crashManager
        self.mainViewModel = mainViewModel
        
        self.documentPicker = ImportDocumentPicker(importManager: self)
    }
    
    func reset() {
        stage = .pickFile
        importProgress = 0
        opmlFolders = []
        selectedFolders = []
        pickedURL = nil
        feedsImported = []
        pagesImported = []
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
    
    func importSelected() {
        stage = .importing
        
        let foldersToImport = opmlFolders.filter { opmlFolder in
            self.selectedFolders.contains(opmlFolder)
        }
        
        self.importFolders(opmlFolders: foldersToImport)
    }
    
    func importFolders(opmlFolders: [OPMLFolder]) {
        guard let profile = mainViewModel.activeProfile else { return }
        opmlFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            pagesImported.append(page)
            
            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page)
                feed.title = opmlFeed.title
                feed.url = opmlFeed.url
                feedsImported.append(feed)
            }
        }
        
        do {
            try viewContext.save()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }
    
    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too, so we do it this way instead of in a UIViewControllerRepresentable
     */
    func pickFile() {
        let viewController = UIApplication.shared.windows[0].rootViewController!
        let controller = self.documentPicker.viewController
        viewController.present(controller, animated: true)
    }
}
