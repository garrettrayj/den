//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.modelContext) private var modelContext

    @Environment(RefreshManager.self) private var refreshManager

    @Binding var detailPanel: DetailPanel?
    
    @State private var exporterIsPresented: Bool = false
    @State private var opmlFile: OPMLFile?
    @State private var searchInput = ""
    
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    @SceneStorage("ShowingExporter") private var showingExporter = false
    @SceneStorage("ShowingImporter") private var showingImporter = false
    @SceneStorage("ShowingSettings") private var showingSettings = false
    
    let pages: [Page]

    @Query(sort: [SortDescriptor(\Search.submitted, order: .reverse)])
    private var searches: [Search]
    
    var body: some View {
        List(selection: $detailPanel) {
            if pages.isEmpty {
                Start()
            } else {
                ApexSection()
                PagesSection(pages: pages)
            }
        }
        .listStyle(.sidebar)
        .buttonStyle(.borderless)
        .badgeProminence(.decreased)
        .lineLimit(1)
        .refreshable {
            await refreshManager.refresh()
        }
        .sensoryFeedback(trigger: refreshManager.refreshing) { _, newValue in
            if newValue == true {
                return .start
            } else {
                return .success
            }
        }
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .searchSuggestions {
            ForEach(searches.prefix(20)) { search in
                if search.wrappedQuery != "" {
                    Text(search.wrappedQuery).searchCompletion(search.wrappedQuery)
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
                feedCount: pages.feeds.count
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MacSidebarBottomBar(feedCount: pages.feeds.count)
        }
        #endif
        .sheet(
            isPresented: $showingSettings,
            content: {
                SettingsSheet()
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
                    modelContext: modelContext,
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
            defaultFilename: {
                let date = Date().formatted(date: .numeric, time: .omitted).sanitizedForFileName()
                return "Den Export \(date)"
            }()
                
        ) { _ in
            opmlFile = nil
        }
        .onChange(of: showingExporter) {
            if showingExporter {
                opmlFile = ImportExportUtility.exportOPML(pages: Array(pages))
            }
            exporterIsPresented = showingExporter
        }
        .onChange(of: exporterIsPresented) {
            if !exporterIsPresented {
                showingExporter = false
            }
        }
    }
}
