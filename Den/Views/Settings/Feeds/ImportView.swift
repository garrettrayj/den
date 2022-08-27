//
//  ImportView.swift
//  Den
//
//  Created by Garrett Johnson on 6/2/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    let profile: Profile

    enum ImportStage {
        case pickFile, folderSelection, error, importing
    }

    @State public var stage: ImportStage = .pickFile
    @State public var opmlFolders: [OPMLReader.Folder] = []
    @State public var selectedFolders: [OPMLReader.Folder] = []
    @State public var pickedURL: URL?

    @State private var feedsImported: [Feed] = []
    @State private var pagesImported: [Page] = []
    @State private var documentPicker: ImportDocumentPicker?

    var body: some View {
        VStack {
            if stage == .pickFile {
                pickFileStage
            } else if stage == .folderSelection {
                folderSelectionStage
            } else if stage == .importing {
                completeStage
            }
        }
        .frame(maxWidth: .infinity)
        .onDisappear(perform: reset)
        .background(Color(UIColor.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Import")
    }

    private var pickFileStage: some View {
        VStack(spacing: 20) {
            Spacer()
            Button(action: pickFile) {
                Label("Select OPML File", systemImage: "filemenu.and.cursorarrow")
            }
            .modifier(ProminentButtonModifier())
            .accessibilityIdentifier("import-pick-file-button")
            Text("You will be able to choose pages to import in the next step")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
            Spacer()
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: 300)
        .padding()
    }

    private var folderSelectionStage: some View {
        Form {
            Section(header: selectionSectionHeader) {
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
                    .accessibilityIdentifier("import-toggle-folder-button")
                }
            }.modifier(SectionHeaderModifier())

            Section {
                Button(action: importSelected) {
                    Label("Import Pages", systemImage: "arrow.down.doc")
                }
                .modifier(ProminentButtonModifier())
                .disabled(!(selectedFolders.count > 0))
                .accessibilityIdentifier("import-submit-button")
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
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
            Text("Added \(feedsImported.count) feeds to \(pagesImported.count) pages")
                .foregroundColor(Color(.secondaryLabel))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .padding()
    }

    private var selectionSectionHeader: some View {
        HStack {
            Text("Select")
            Spacer()
            HStack {
                Button(action: selectAll) { Text("All") }
                    .disabled(allSelected)
                    .accessibilityIdentifier("import-select-all-button")
                Text("/").foregroundColor(.secondary)
                Button(action: selectNone) { Text("None") }
                    .disabled(noneSelected)
                    .accessibilityIdentifier("import-select-none-button")
            }
            .font(.system(size: 12))
        }
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
        stage = .importing

        let foldersToImport = opmlFolders.filter { opmlFolder in
            self.selectedFolders.contains(opmlFolder)
        }

        self.importFolders(opmlFolders: foldersToImport)
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
            CrashManager.handleCriticalError(error)
        }
    }

    /**
     Presents the document picker from the root view controller.
     This is required on Catalyst but works on iOS and iPadOS too,
     so we do it this way instead of in a UIViewControllerRepresentable
     */
    private func pickFile() {
        self.documentPicker = ImportDocumentPicker(view: self)

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
