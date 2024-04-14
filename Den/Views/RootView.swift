//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth
    @Environment(\.userTint) private var userTint
    
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var refreshing = false
    @State private var refreshProgress = Progress()
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingNewFeedSheet = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false
    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false
    
    @StateObject private var navigationStore = NavigationStore()
    
    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?
    @SceneStorage("Navigation") private var navigationData: Data?
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("HideRead") private var hideRead: Bool = false
    @AppStorage("MaintenanceTimestamp") private var maintenanceTimestamp: Double?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var pages: FetchedResults<Page>

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                detailPanel: $detailPanel,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                searchQuery: $searchQuery,
                showingExporter: $showingExporter,
                showingImporter: $showingImporter,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewPageSheet: $showingNewPageSheet,
                showingNewTagSheet: $showingNewTagSheet,
                refreshing: $refreshing,
                refreshProgress: $refreshProgress,
                pages: pages
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
            #else
            .navigationSplitViewColumnWidth(ideal: 280)
            #endif
        } detail: {
            DetailView(
                detailPanel: $detailPanel,
                hideRead: $hideRead,
                path: $navigationStore.path,
                searchQuery: $searchQuery
            )
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            #endif
        }
        .background {
            // Buttons in background for keyboard shortcuts
            Group {
                NewFeedButton(showingNewFeedSheet: $showingNewFeedSheet)
                NewPageButton(showingNewPageSheet: $showingNewPageSheet)
                NewTagButton(showingNewTagSheet: $showingNewTagSheet)
                RefreshButton().disabled(
                    refreshing || !networkMonitor.isConnected || pages.isEmpty
                )
            }
            .opacity(0)
        }
        .tint(accentColor?.color)
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
                webAddress: $newFeedWebAddress,
                initialPageID: $newFeedPageID
            )
        }
        // Refresh notifications
        .onReceive(
            NotificationCenter.default.publisher(for: .refreshStarted, object: nil)
        ) { _ in
            refreshProgress.totalUnitCount = Int64(pages.feeds.count)
            refreshing = true
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .refreshProgressed, object: nil)
        ) { _ in
            refreshProgress.completedUnitCount += 1
        }
        .onReceive(
            NotificationCenter.default.publisher(for: .refreshFinished, object: nil)
        ) { _ in
            refreshing = false
            refreshProgress.completedUnitCount = 0
            pages.forEach { page in
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
        .environment(\.userTint, accentColor?.color)
        .environment(\.useSystemBrowser, useSystemBrowser)
        .preferredColorScheme(userColorScheme.colorScheme)
        .onReceive(NotificationCenter.default.publisher(for: .appErrored, object: nil)) { output in
            if let message = output.userInfo?["message"] as? String {
                appErrorMessage = message
            }
            showingAppErrorSheet = true
        }
        .sheet(isPresented: $showingAppErrorSheet) {
            AppErrorSheet(message: $appErrorMessage).interactiveDismissDisabled()
        }
        .task {
            await BlocklistManager.initializeMissingContentRulesLists()
            await performMaintenance()
            
            CleanupUtility.upgradeBookmarks(context: viewContext)
        }
    }
    
    private func performMaintenance() async {
        if let maintenanceTimestamp = maintenanceTimestamp {
            let nextMaintenanceDate = Date(
                timeIntervalSince1970: maintenanceTimestamp
            ) + 7 * 24 * 60 * 60
            
            if nextMaintenanceDate > .now {
                Logger.main.info("""
                Next maintenance operation will be performed after \
                \(nextMaintenanceDate.formatted(), privacy: .public)
                """)
                return
            }
        }

        try? CleanupUtility.removeExpiredHistory(context: viewContext)
        CleanupUtility.trimSearches(context: viewContext)

        try? CleanupUtility.purgeOrphans(context: viewContext)
        
        await BlocklistManager.cleanupContentRulesLists()
        await BlocklistManager.refreshAllContentRulesLists()

        try? viewContext.save()

        maintenanceTimestamp = Date.now.timeIntervalSince1970
    }
}
