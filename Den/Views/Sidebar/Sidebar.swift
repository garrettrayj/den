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
    
    @EnvironmentObject private var dataController: DataController
    @EnvironmentObject private var refreshManager: RefreshManager

    @Binding var detailPanel: DetailPanel?
    
    @State private var exporterIsPresented: Bool = false
    @State private var opmlFile: OPMLFile?
    @State private var searchInput = ""
    
    let pages: FetchedResults<Page>
    
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    @SceneStorage("ShowingNewPageSheet") private var showingNewPageSheet = false
    @SceneStorage("ShowingImporter") private var showingImporter: Bool = false
    @SceneStorage("ShowingExporter") private var showingExporter: Bool = false
    @SceneStorage("ShowingSettings") private var showingSettings: Bool = false

    @FetchRequest(sortDescriptors: [SortDescriptor(\.submitted, order: .reverse)])
    private var searches: FetchedResults<Search>
    
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
            await refreshManager.refresh(container: dataController.container)
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
        .toolbar { toolbarContent }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MacSidebarBottomBar(feedCount: pages.feeds.count)
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

    private func saveChanges() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
        }
    }
    
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            Menu {
                NewFeedButton()
                NewPageButton()
                Divider()
                ImportButton()
                ExportButton()
                Divider()
                OrganizerButton(detailPanel: $detailPanel)
                #if os(macOS)
                SettingsLink()
                #else
                SettingsButton()
                #endif
            } label: {
                Label {
                    Text("Menu", comment: "Menu label.")
                } icon: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .disabled(refreshManager.refreshing)
            .menuIndicator(.hidden)
            .help(Text("Show menu", comment: "Menu help text."))
            .accessibilityIdentifier("SidebarMenu")
        }
        #if os(iOS)
        ToolbarItem(placement: .status) {
            SidebarStatus(feedCount: pages.feeds.count).layoutPriority(0)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton().disabled(pages.feeds.count == 0)
        }
        #endif
    }
}
