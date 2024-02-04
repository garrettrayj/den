//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var lastProfileID: String?
    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool
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
    
    let profiles: [Profile]

    var body: some View {
        List(selection: $detailPanel) {
            if profile.pagesArray.isEmpty {
                Start(
                    profile: profile,
                    showingImporter: $showingImporter,
                    showingNewPageSheet: $showingNewPageSheet
                )
            } else {
                ApexSection(profile: profile)

                PagesSection(
                    profile: profile,
                    newFeedPageID: $newFeedPageID,
                    newFeedWebAddress: $newFeedWebAddress,
                    showingNewFeedSheet: $showingNewFeedSheet
                )
                
                if !profile.tagsArray.isEmpty {
                    TagsSection(profile: profile)
                }
            }
        }
        .listStyle(.sidebar)
        .buttonStyle(.borderless)
        .badgeProminence(.decreased)
        .refreshable {
            await RefreshManager.refresh(profile: profile)
        }
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .searchSuggestions {
            ForEach(profile.searchesArray.prefix(20)) { search in
                if search.wrappedQuery != "" {
                    Text(verbatim: search.wrappedQuery).searchCompletion(search.wrappedQuery)
                }
            }
        }
        .onSubmit(of: .search) {
            searchQuery = searchInput.trimmingCharacters(in: .whitespacesAndNewlines)
            detailPanel = .search
        }
        .navigationTitle(profile.nameText)
        .toolbar {
            SidebarToolbar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewPageSheet: $showingNewPageSheet,
                showingNewTagSheet: $showingNewTagSheet,
                showingSettings: $showingSettings,
                profiles: profiles
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            MacSidebarBottomBar(
                profile: profile,
                currentProfileID: $currentProfileID,
                lastProfileID: $lastProfileID,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                profiles: profiles
            )
        }
        #endif
        .sheet(
            isPresented: $showingSettings,
            onDismiss: {
                if !profile.isDeleted {
                    saveChanges()
                }
            },
            content: {
                SettingsSheet(
                    profiles: profiles,
                    currentProfileID: $currentProfileID,
                    userColorScheme: $userColorScheme,
                    useSystemBrowser: $useSystemBrowser
                )
            }
        )
        .sheet(
            isPresented: $showingNewPageSheet,
            onDismiss: saveChanges,
            content: {
                NewPageSheet(profile: profile)
            }
        )
        .sheet(
            isPresented: $showingNewTagSheet,
            onDismiss: saveChanges,
            content: {
                NewTagSheet(profile: profile)
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
                ImportExportUtility.importOPML(url: selectedFile, context: viewContext, profile: profile)
            } else {
                // Handle denied access
            }
        }
        .fileExporter(
            isPresented: $exporterIsPresented,
            document: opmlFile,
            contentType: UTType(importedAs: "public.opml"),
            defaultFilename: profile.exportTitle.sanitizedForFileName()
        ) { _ in
            opmlFile = nil
        }
        .onChange(of: showingExporter) {
            if showingExporter {
                opmlFile = ImportExportUtility.exportOPML(profile: profile)
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
