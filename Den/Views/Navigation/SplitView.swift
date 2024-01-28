//
//  SplitView.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import CoreData
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct SplitView: View {
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth
    @Environment(\.userTint) private var userTint

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var refreshing: Bool
    @Binding var showingExporter: Bool
    @Binding var showingImporter: Bool
    @Binding var showingNewFeedSheet: Bool
    @Binding var showingNewPageSheet: Bool
    @Binding var showingNewTagSheet: Bool
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    let profiles: [Profile]
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    
    @State private var refreshProgress = Progress()

    @StateObject private var navigationStore = NavigationStore()

    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?
    @SceneStorage("Navigation") private var navigationData: Data?
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    
    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                userColorScheme: $userColorScheme,
                useSystemBrowser: $useSystemBrowser,
                searchQuery: $searchQuery,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewPageSheet: $showingNewPageSheet,
                showingNewTagSheet: $showingNewTagSheet,
                refreshing: $refreshing, 
                refreshProgress: $refreshProgress,
                profiles: profiles
            )
            .navigationSplitViewColumnWidth(min: 220, ideal: 300, max: 300)
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel, 
                hideRead: $hideRead,
                path: $navigationStore.path,
                searchQuery: $searchQuery
            )
            .navigationSplitViewColumnWidth(min: minDetailColumnWidth, ideal: 600)
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            .toolbarBackground(.visible)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            #endif
        }
        .tint(userTint)
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
        .onOpenURL { url in
            if case .page(let page) = detailPanel {
                newFeedPageID = page.id?.uuidString
            }
            newFeedWebAddress = url.absoluteStringForNewFeed
            showingNewFeedSheet = true
        }
        .task {
            if let navigationData {
                navigationStore.restore(from: navigationData)
            }
            for await _ in navigationStore.$path.values.map({ $0.count }) {
                navigationData = navigationStore.encoded()
            }
        }
        .onChange(of: currentProfileID) {
            detailPanel = nil
        }
        .onChange(of: detailPanel) {
            navigationStore.path.removeLast(navigationStore.path.count)
        }
        .onChange(of: showingNewFeedSheet) {
            if showingNewFeedSheet {
                guard
                    newFeedPageID == nil,
                    case .page(let page) = detailPanel
                else { return }
                newFeedPageID = page.id?.uuidString
            } else {
                newFeedPageID = nil
                newFeedWebAddress = ""
            }
        }
        .sheet(isPresented: $showingNewFeedSheet) {
            NewFeedSheet(
                profile: profile,
                webAddress: $newFeedWebAddress,
                initialPageID: $newFeedPageID
            )
        }
        .navigationTitle(profile.nameText)
        .onReceive(NotificationCenter.default.publisher(for: .refreshTriggered, object: nil)) { _ in
            Task {
                await RefreshManager.refresh(profile: profile)
            }
        }
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
    }
}
