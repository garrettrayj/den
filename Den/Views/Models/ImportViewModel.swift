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
    @Published var opmlFolders: [OPMLFolder] = []
    @Published var selectedFolders: [OPMLFolder] = []
    @Published var pickedURL: URL?
    @Published var feedsImported: [Feed] = []
    @Published var pagesImported: [Page] = []

    private var viewContext: NSManagedObjectContext

    var contentViewModel: ContentViewModel
    var documentPicker: ImportDocumentPicker!
    var allSelected: Bool { selectedFolders.count == opmlFolders.count }
    var noneSelected: Bool { selectedFolders.count == 0 }

    init(viewContext: NSManagedObjectContext, contentViewModel: ContentViewModel) {
        self.viewContext = viewContext
        self.contentViewModel = contentViewModel

        self.documentPicker = ImportDocumentPicker(importViewModel: self)
    }

    func reset() {
        stage = .pickFile
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
        guard let profile = contentViewModel.activeProfile else { return }
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
        } catch let error as NSError {
            contentViewModel.handleCriticalError(error)
        }
    }

    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too,
     so we do it this way instead of in a UIViewControllerRepresentable
     */
    func pickFile() {
        let scenes = UIApplication.shared.connectedScenes

        if
            let windowScene = scenes.first as? UIWindowScene,
            let window = windowScene.windows.first,
            let viewController = window.rootViewController
        {
            let controller = self.documentPicker.viewController
            viewController.present(controller, animated: true)
        }
    }
}
