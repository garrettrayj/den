//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext

    @Binding var detailPanel: DetailPanel?
    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var searchQuery: String
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var refreshing: Bool
    @Binding var refreshProgress: Progress
    
    @State private var exporterIsPresented: Bool = false
    @State private var opmlFile: OPMLFile?
    @State private var searchInput = ""
    @State private var showingSettings = false
    
    let pages: FetchedResults<Page>
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var tags: FetchedResults<Tag>

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.submitted, order: .reverse)
    ])
    private var searches: FetchedResults<Search>
    
    var body: some View {
        List(selection: $detailPanel) {
            if pages.isEmpty {
                Start(
                    showingImporter: $showingImporter,
                    showingNewPageSheet: $showingNewPageSheet
                )
            } else {
                ApexSection()

                PagesSection(
                    newFeedPageID: $newFeedPageID,
                    newFeedWebAddress: $newFeedWebAddress,
                    showingNewFeedSheet: $showingNewFeedSheet,
                    pages: pages
                )
                
                if !tags.isEmpty {
                    TagsSection(tags: tags)
                }
            }
        }
        .listStyle(.sidebar)
        .buttonStyle(.borderless)
        .badgeProminence(.decreased)
        .refreshable {
            await RefreshManager.refresh()
        }
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .searchSuggestions {
            ForEach(searches.prefix(20)) { search in
                if search.wrappedQuery != "" {
                    Text(verbatim: search.wrappedQuery).searchCompletion(search.wrappedQuery)
                }
            }
        }
        .onSubmit(of: .search) {
            searchQuery = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
            detailPanel = .search
        }
        .toolbar {
            SidebarToolbar(
                detailPanel: $detailPanel,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewPageSheet: $showingNewPageSheet,
                showingNewTagSheet: $showingNewTagSheet,
                showingSettings: $showingSettings, 
                pages: pages
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MacSidebarBottomBar(
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                pages: pages
            )
        }
        #endif
        .sheet(
            isPresented: $showingSettings,
            onDismiss: {
                saveChanges()
            },
            content: {
                SettingsSheet()
            }
        )
        .sheet(
            isPresented: $showingNewPageSheet,
            onDismiss: saveChanges,
            content: {
                NewPageSheet()
            }
        )
        .sheet(
            isPresented: $showingNewTagSheet,
            onDismiss: saveChanges,
            content: {
                NewTagSheet()
            }
        )
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.init(importedAs: "public.opml"), .xml],
            allowsMultipleSelection: false
        ) { result in
            guard let selectedFile: URL = try? result.get().first else { return }
            if selectedFile.startAccessingSecurityScopedResource() {
                defer { selectedFile.stopAccessingSecurityScopedResource() }
                ImportExportUtility.importOPML(
                    url: selectedFile,
                    context: viewContext,
                    pageUserOrderMax: pages.maxUserOrder
                )
            } else {
                // Handle denied access
            }
        }
        .fileExporter(
            isPresented: $exporterIsPresented,
            document: opmlFile,
            contentType: UTType(importedAs: "public.opml"),
            defaultFilename: "Den Export"
        ) { _ in
            opmlFile = nil
        }
        .onChange(of: showingExporter) {
            if showingExporter {
                opmlFile = ImportExportUtility.exportOPML()
            }
            exporterIsPresented = showingExporter
        }
        .onChange(of: exporterIsPresented) {
            if !exporterIsPresented {
                showingExporter = false
            }
        }
    }

    private func saveChanges() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
}
