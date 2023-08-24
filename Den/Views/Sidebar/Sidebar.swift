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

struct Sidebar: View {
    @Environment(\.managedObjectContext) private var viewContext
    #if os(iOS)
    @Environment(\.editMode) private var editMode
    #endif

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var detailPanel: DetailPanel?
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingProfileSettings: Bool

    @State private var searchInput = ""
    @State private var isEditing = false

    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress

    var body: some View {
        List(selection: $detailPanel) {
            if profile.pagesArray.isEmpty {
                Start(profile: profile, detailPanel: $detailPanel, showingImporter: $showingImporter)
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

                PagesSection(profile: profile)
            }
        }
        .listStyle(.sidebar)
        .searchable(
            text: $searchInput,
            placement: .sidebar,
            prompt: Text("Search", comment: "Search field prompt.")
        )
        .searchSuggestions {
            ForEach(profile.searchesArray.prefix(10)) { search in
                if search.wrappedQuery != "" {
                    Text(verbatim: search.wrappedQuery).searchCompletion(search.wrappedQuery)
                }
            }
        }
        .onSubmit(of: .search) {
            if let search = profile.searchesArray.first(where: { $0.query == searchInput }) {
                search.submitted = Date()
                do {
                    try viewContext.save()
                    detailPanel = .search(search)
                } catch {
                    CrashUtility.handleCriticalError(error as NSError)
                }
                return
            }

            let search = Search.create(
                in: viewContext,
                profile: profile,
                query: searchInput
            )
            do {
                try viewContext.save()
                detailPanel = .search(search)
            } catch {
                CrashUtility.handleCriticalError(error as NSError)
            }
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
                showingProfileSettings: $showingProfileSettings,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
        }
        #if os(macOS)
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading) {
                Menu {
                    NewProfileButton(currentProfileID: $currentProfileID)
                    ProfilePicker(currentProfileID: $currentProfileID, profiles: profiles)
                        .pickerStyle(.inline)
                } label: {
                    Label {
                        profile.nameText
                    } icon: {
                        Image(systemName: "person.crop.circle").imageScale(.large)
                    }
                }
                .labelStyle(.titleAndIcon)
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
    }
}
