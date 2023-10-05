//
//  Sidebar.swift
//  Den
//
//  Created by Garrett Johnson on 12/6/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import SwiftUI
import UniformTypeIdentifiers

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var newFeedPageID: String?
    @Binding var newFeedWebAddress: String
    @Binding var refreshing: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewProfileSheet: Bool

    @State private var exporterIsPresented: Bool = false
    @State private var isEditing = false
    @State private var opmlFile: OPMLFile?
    @State private var searchInput = ""
    @State private var showingExporter: Bool = false
    @State private var showingImporter: Bool = false
    @State private var showingProfileOptions = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false

    let profiles: [Profile]
    let refreshProgress: Progress

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
        .listStyle(.sidebar)
        .badgeProminence(.decreased)
        .refreshable {
            await RefreshManager.refresh(profile: profile)
        }
        .id(profile.id) // Needed for refreshable action to update when switching profiles
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
            detailPanel = .search(searchInput)
        }
        #if os(iOS)
        .environment(\.editMode, .constant(self.isEditing ? EditMode.active : EditMode.inactive))
        #endif
        .disabled(refreshing)
        .navigationTitle(profile.nameText)
        .toolbar {
            SidebarToolbar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                isEditing: $isEditing,
                refreshing: $refreshing,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewPageSheet: $showingNewPageSheet,
                showingNewProfileSheet: $showingNewProfileSheet,
                showingNewTagSheet: $showingNewTagSheet,
                showingProfileOptions: $showingProfileOptions,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading) {
                Menu {
                    NewProfileButton(showingNewProfileSheet: $showingNewProfileSheet)
                        .labelStyle(.titleAndIcon)
                    ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
                        .pickerStyle(.inline)
                } label: {
                    Label {
                        profile.nameText
                    } icon: {
                        Image(systemName: "person.crop.circle").imageScale(.large)
                    }
                }
                .menuStyle(.borderlessButton)
                .menuIndicator(.hidden)
                .menuOrder(.fixed)
                .accessibilityIdentifier("ProfileMenu")
                .disabled(refreshing)

                SidebarStatus(profile: profile, progress: refreshProgress, refreshing: $refreshing)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        #endif
        .sheet(
            isPresented: $showingProfileOptions,
            onDismiss: {
                if !profile.isDeleted {
                    saveChanges()
                }
            },
            content: {
                ProfileOptionsSheet(
                    profile: profile,
                    currentProfileID: $currentProfileID
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
