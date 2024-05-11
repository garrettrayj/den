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
    
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingNewFeedSheet = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false
    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false
    @State private var clearPathOnDetailChange = true
    
    @StateObject private var navigationStore = NavigationStore()
    
    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?
    @SceneStorage("Navigation") private var navigationData: Data?
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    
    @AppStorage("HideRead") private var hideRead: Bool = false
    @AppStorage("MaintenanceTimestamp") private var maintenanceTimestamp: Double?
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("RefreshInterval") private var refreshInterval: RefreshInterval = .threeHours
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var pages: FetchedResults<Page>
    
    @ScaledMetric var sidebarWidth = 264

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
                pages: pages
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 300)
            #else
            // On iOS, sidebar width changes are appplied when app is relaunched.
            .navigationSplitViewColumnWidth(sidebarWidth)
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
            }
            .disabled(pages.isEmpty)
            .opacity(0)
        }
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
        .onOpenURL { url in
            if url.scheme == "den+widget" {
                openWidgetURL(url: url)
            } else {
                if case .page(let page) = detailPanel {
                    newFeedPageID = page.id?.uuidString
                }
                newFeedWebAddress = url.absoluteStringForNewFeed
                showingNewFeedSheet = true
            }
        }
        .task {
            if let navigationData {
                navigationStore.restore(from: navigationData)
            }

            for await _ in navigationStore.$path.values.map({ $0.count }) {
                navigationData = navigationStore.encoded()
            }
            
            await BlocklistManager.initializeMissingContentRulesLists()
            await performMaintenance()
            
            CleanupUtility.upgradeBookmarks(context: viewContext)
            
            #if os(macOS)
            startStopAutoRefresh()
            #endif
        }
        #if os(macOS)
        .onChange(of: refreshInterval) {
            startStopAutoRefresh()
        }
        #endif
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
        .onReceive(NotificationCenter.default.publisher(for: .appErrored, object: nil)) { output in
            if let message = output.userInfo?["message"] as? String {
                appErrorMessage = message
            }
            showingAppErrorSheet = true
        }
        .sheet(isPresented: $showingAppErrorSheet) {
            AppErrorSheet(message: $appErrorMessage).interactiveDismissDisabled()
        }
        .preferredColorScheme(userColorScheme.colorScheme)
        .tint(accentColor?.color)
    }
    
    #if os(macOS)
    private func startStopAutoRefresh() {
        if refreshInterval == .zero {
            refreshManager.stopAutoRefresh()
        } else {
            refreshManager.startAutoRefresh(interval: TimeInterval(refreshInterval.rawValue))
        }
    }
    #endif
    
    private func openWidgetURL(url: URL) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        
        // Restore detail panel from widget source
        let sourceType = url.pathComponents[1]
        var sourceID: UUID?
        if url.pathComponents.indices.contains(2) {
            sourceID = UUID(uuidString: url.pathComponents[2])
        }
        
        withAnimation {
            if sourceType == "inbox" {
                detailPanel = .inbox
            } else if sourceType == "page" {
                if let page = pages.first(where: { $0.id == sourceID }) {
                    detailPanel = .page(page)
                }
            } else if sourceType == "feed" {
                if let feed = pages.flatMap({ $0.feedsArray }).first(where: { $0.id == sourceID }) {
                    detailPanel = .feed(feed)
                }
            }
        } completion: {
            if !navigationStore.path.isEmpty {
                navigationStore.path.removeLast(navigationStore.path.count)
            }
            
            // Restore item sub-detail view
            if let itemID = urlComponents.queryItems?.first(
                where: {$0.name == "item"}
            )?.value {
                let request = Item.fetchRequest()
                request.predicate = NSPredicate(format: "id = %@", itemID)
                
                if let item = try? viewContext.fetch(request).first {
                    navigationStore.path.append(SubDetailPanel.item(item))
                }
            }
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
