//
//  ImportViewModel.swift
//  Den
//
//  Created by Garrett Johnson on 8/19/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

final class ImportViewModel: ObservableObject {
    enum ImportStage {
        case pickFile, folderSelection, error, importing
    }

    @Published var stage: ImportStage = .pickFile
    @Published var opmlFolders: [OPMLReader.Folder] = []
    @Published var selectedFolders: [OPMLReader.Folder] = []
    @Published var pickedURL: URL?
    @Published var feedsImported: [Feed] = []
    @Published var pagesImported: [Page] = []

    var allSelected: Bool {

        print(selectedFolders.count)
        print(opmlFolders.count)
        return selectedFolders.count == opmlFolders.count
    }
    var noneSelected: Bool { selectedFolders.count == 0 }

    private var viewContext: NSManagedObjectContext
    private var crashManager: CrashManager
    private var profileManager: ProfileManager
    private var documentPicker: ImportDocumentPicker?

    init(viewContext: NSManagedObjectContext, crashManager: CrashManager, profileManager: ProfileManager) {
        self.viewContext = viewContext
        self.crashManager = crashManager
        self.profileManager = profileManager
    }

    func reset() {
        stage = .pickFile
        opmlFolders = []
        selectedFolders = []
        pickedURL = nil
        feedsImported = []
        pagesImported = []
    }

    func toggleFolder(_ folder: OPMLReader.Folder) {
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

    func importFolders(opmlFolders: [OPMLReader.Folder]) {
        guard let profile = profileManager.activeProfile else { return }
        opmlFolders.forEach { opmlFolder in
            let page = Page.create(in: self.viewContext, profile: profile)
            page.name = opmlFolder.name
            pagesImported.append(page)

            opmlFolder.feeds.forEach { opmlFeed in
                let feed = Feed.create(in: self.viewContext, page: page, url: opmlFeed.url)
                feed.title = opmlFeed.title
                feedsImported.append(feed)
            }
        }

        do {
            try viewContext.save()
            profileManager.objectWillChange.send()
        } catch let error as NSError {
            crashManager.handleCriticalError(error)
        }
    }

    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too,
     so we do it this way instead of in a UIViewControllerRepresentable
     */
    func pickFile() {
        self.documentPicker = ImportDocumentPicker(importViewModel: self)

        let scenes = UIApplication.shared.connectedScenes
        if
            let windowScene = scenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let rootViewController = window.rootViewController,
            let pickerViewController = documentPicker?.viewController
        {
            rootViewController.present(pickerViewController, animated: true)
        }
    }
}
