//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext

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

    @AppStorage("ShowUnreadCounts") private var showUnreadCounts = true
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.submitted, order: .reverse)])
    private var searches: FetchedResults<Search>
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.feedData?.feedId)],
        predicate: NSPredicate(format: "extra = %@", NSNumber(value: false))
    )
    private var items: FetchedResults<Item>
    
    var body: some View {
        List(selection: $detailPanel) {
            if pages.isEmpty {
                Start()
            } else {
                Section {
                    InboxNavLink(items: items)
                    TrendingNavLink()
                    BookmarksNavLink()
                }
                Section {
                    ForEach(pages) { page in
                        SidebarPage(page: page, items: items.forPage(page))
                    }
                    .onMove(perform: movePages)
                    .onDelete(perform: deletePages)
                } header: {
                    Text("Folders", comment: "Sidebar section header.")
                }
            }
        }
        .navigationTitle(Bundle.main.name)
        .listStyle(.sidebar)
        .buttonStyle(.borderless)
        .badgeProminence(.decreased)
        .lineLimit(1)
        .environment(\.showUnreadCounts, showUnreadCounts)
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
        .toolbar { toolbarContent }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MacSidebarBottomBar(feedCount: pages.feeds.count)
        }
        #endif
        .sheet(isPresented: $showingSettings) {
            SettingsSheet()
        }
        .sheet(isPresented: $showingNewPageSheet) {
            NewPageSheet()
        }
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

    private func movePages(from source: IndexSet, to destination: Int) {
        var revisedItems = Array(pages)

        // Change the order of the items in the array
        revisedItems.move(fromOffsets: source, toOffset: destination)

        // Update the userOrder attribute in revisedItems to persist the new order.
        // This is done in reverse order to minimize changes to the indices.
        for reverseIndex in stride(from: revisedItems.count - 1, through: 0, by: -1 ) {
            revisedItems[reverseIndex].userOrder = Int16(reverseIndex)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
        }
    }

    private func deletePages(at offsets: IndexSet) {
        for index in offsets {
            let page = pages[index]
            page.feedsArray.compactMap { $0.feedData }.forEach { viewContext.delete($0) }
            viewContext.delete(page)
        }

        do {
            try viewContext.save()
        } catch {
            CrashUtility.handleCriticalError(error as NSError)
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
            SidebarStatus(feedCount: pages.feeds.count)
        }
        ToolbarItem(placement: .bottomBar) {
            RefreshButton().disabled(pages.feeds.count == 0)
        }
        #endif
    }
}
