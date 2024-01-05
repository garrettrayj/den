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
    @State private var isEditing = false
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
                #if os(macOS)
                Section {
                    InboxNavLink(profile: profile)
                    TrendingNavLink(profile: profile)
                } header: {
                    Text("All Feeds", comment: "Sidebar section header.")
                }
                #else
                InboxNavLink(profile: profile)
                TrendingNavLink(profile: profile)
                #endif
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
        .buttonStyle(.plain)
        .listStyle(.sidebar)
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
        #if os(iOS)
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        #endif
        .navigationTitle(profile.nameText)
        .toolbar {
            SidebarToolbar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                isEditing: $isEditing,
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
        .safeAreaInset(edge: .bottom) {
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
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
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
            profile.pagesArray.forEach { $0.objectWillChange.send() }
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
