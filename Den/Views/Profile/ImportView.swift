//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImportView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    enum ImportStage {
        case pickFile, folderSelection, error, complete
    }

    @State private var stage: ImportStage = .pickFile
    @State private var opmlFolders: [OPMLReader.Folder] = []
    @State private var selectedFolders: [OPMLReader.Folder] = []
    @State private var pickedURL: URL?
    @State private var feedsImported: [Feed] = []
    @State private var pagesImported: [Page] = []
    @State private var documentPicker: ImportDocumentPicker?

    var body: some View {
        VStack {
            if stage == .pickFile {
                pickFileStage
            } else if stage == .folderSelection {
                folderSelectionStage
            } else if stage == .complete {
                completeStage
            }
        }
        .frame(maxWidth: .infinity)
        .onDisappear(perform: reset)
        .navigationTitle("Import")
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                if stage == .pickFile {
                    Button(action: pickFile) {
                        Label("Select File", systemImage: "filemenu.and.cursorarrow")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(PlainToolbarButtonStyle())
                    .accessibilityIdentifier("select-file-button")
                } else if stage == .folderSelection {
                    Button(action: importSelected) {
                        Label("Import Pages", systemImage: "rectangle.stack.badge.plus")
                            .labelStyle(.titleAndIcon)
                    }
                    .buttonStyle(PlainToolbarButtonStyle())
                    .disabled(!(selectedFolders.count > 0))
                    .accessibilityIdentifier("import-button")
                }
            }
        }
    }

    private var pickFileStage: some View {
        VStack {
            Spacer()
            Text("""
            First choose an OPML file to add feeds from. Pick pages to import next.
            """)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        }
    }

    private var folderSelectionStage: some View {
        Form {
            Section(header: selectionSectionHeader.modifier(FirstFormHeaderModifier())) {
                ForEach(opmlFolders, id: \.name) { folder in
                    Button { toggleFolder(folder) } label: {
                        Label {
                            HStack {
                                Text(folder.name).foregroundColor(.primary)
                                Spacer()
                                Text("\(folder.feeds.count) feeds")
                                    .foregroundColor(.secondary)
                                    .font(.footnote)
                            }
                        } icon: {
                            if selectedFolders.contains(folder) {
                                Image(systemName: "checkmark.circle.fill")
                            } else {
                                Image(systemName: "circle")
                            }
                        }.lineLimit(1)
                    }
                    .modifier(FormRowModifier())
                    .accessibilityIdentifier("toggle-folder-button")
                }
            }
            .modifier(ListRowModifier())
        }
    }

    private var errorStage: some View {
        SplashNote(
            title: "Import Error",
            note: "The operation did not complete successfully."
        )
    }

    private var completeStage: some View {
        SplashNote(
            title: "Import Complete",
            note: "\(pagesImported.count) pages with \(feedsImported.count) feeds added to profile."
        )
    }

    private var selectionSectionHeader: some View {
        BulkSelectionButtons(
            allSelected: allSelected,
            noneSelected: noneSelected,
            selectAll: selectAll,
            selectNone: selectNone
        )
    }

    private var allSelected: Bool {
        return selectedFolders.count == opmlFolders.count
    }

    private var noneSelected: Bool { selectedFolders.isEmpty }

    private func reset() {
        stage = .pickFile
        opmlFolders = []
        selectedFolders = []
        pickedURL = nil
        feedsImported = []
        pagesImported = []
    }

    private func toggleFolder(_ folder: OPMLReader.Folder) {
        if selectedFolders.contains(folder) {
            selectedFolders.removeAll { $0 == folder }
        } else {
            selectedFolders.append(folder)
        }
    }

    private func selectAll() {
        opmlFolders.forEach { folder in
            if !selectedFolders.contains(folder) {
                selectedFolders.append(folder)
            }
        }
    }

    private func selectNone() {
        selectedFolders.removeAll()
    }

    private func importSelected() {
        let foldersToImport = opmlFolders.filter { opmlFolder in
            self.selectedFolders.contains(opmlFolder)
        }
        self.importFolders(opmlFolders: foldersToImport)
        stage = .complete
        Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
    }

    private func importFolders(opmlFolders: [OPMLReader.Folder]) {
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
            CrashUtility.handleCriticalError(error)
        }
    }

    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too,
     so we do it this way instead of in a UIViewControllerRepresentable
     */
    private func pickFile() {
        self.documentPicker = ImportDocumentPicker(callback: { urls in
            guard let url = urls.first else { return }
            pickedURL = url
            opmlFolders = OPMLReader(xmlURL: url).outlineFolders
            selectedFolders = opmlFolders
            stage = .folderSelection
        })

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
