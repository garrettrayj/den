//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext

    @EnvironmentObject private var networkMonitor: NetworkMonitor

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool
    @Binding var searchQuery: String
    @Binding var showingNewFeedSheet: Bool

    @State private var exporterIsPresented: Bool = false
    @State private var opmlFile: OPMLFile?
    @State private var refreshing = false
    @State private var refreshProgress = Progress()
    @State private var searchInput = ""
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingSettings = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false

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
            HStack {
                VStack(alignment: .leading) {
                    ProfilePickerMenu(
                        profile: profile,
                        profiles: profiles,
                        currentProfileID: $currentProfileID
                    )
                    .disabled(refreshing)

                    SidebarStatus(
                        profile: profile,
                        refreshing: $refreshing,
                        refreshProgress: $refreshProgress
                    )
                }
                
                RefreshButton(
                    profile: profile,
                    refreshing: $refreshing,
                    refreshProgress: $refreshProgress
                )
                .labelStyle(.iconOnly)
                .imageScale(.large)
                .buttonStyle(.borderless)
                .disabled(refreshing || !networkMonitor.isConnected || profile.pagesArray.isEmpty)
            }
            
            .padding(12)
            .padding(.top, 1)
            .background(alignment: .top) {
                Rectangle().fill(BackgroundSeparatorShapeStyle()).frame(height: 1)
            }
        }
        #endif
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            refreshProgress.totalUnitCount = Int64(profile.feedsArray.count)
            refreshing = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .refreshProgressed, object: profile.objectID)
        ) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)
        ) { _ in
            refreshing = false
            refreshProgress.completedUnitCount = 0
            profile.objectWillChange.send()
            profile.pagesArray.forEach { page in
                page.objectWillChange.send()
                page.feedsArray.forEach { $0.objectWillChange.send() }
            }
        }
        .sensoryFeedback(trigger: refreshing) { _, newValue in
            if newValue == true {
                return .start
            } else {
                return .success
            }
        }
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
        .background {
            // Buttons in background for keyboard shortcuts
            ZStack {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
            }.opacity(0)
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
