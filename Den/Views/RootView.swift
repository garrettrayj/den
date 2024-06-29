//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import OSLog
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    #if os(iOS)
    @Environment(\.scenePhase) private var scenePhase
    #endif
    
    @Environment(RefreshManager.self) private var refreshManager
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var showingExporter = false
    @State private var showingImporter = false
    @State private var showingNewFeedSheet = false
    @State private var showingNewPageSheet = false
    @State private var showingNewTagSheet = false
    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false
    @State private var clearPathOnDetailChange = true
    @State private var detailPanel: DetailPanel?
    @State private var navigationStore = NavigationStore()
    @State private var newFeed: Feed?
    @State private var newFeedPageID: String?
    @State private var newFeedURLString: String = ""
    
    @SceneStorage("DetailPanel") private var detailPanelData: Data?
    @SceneStorage("Navigation") private var navigationData: Data?
    @SceneStorage("SearchQuery") private var searchQuery: String = ""
    
    @AppStorage("Maintained") private var maintenanceTimestamp: Double?
    @AppStorage("AccentColor") private var accentColor: AccentColor?
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("RefreshInterval") private var refreshInterval: RefreshInterval = .zero
    
    @Query(sort: [
        SortDescriptor(\Page.userOrder, order: .forward),
        SortDescriptor(\Page.name, order: .forward)
    ])
    private var pages: [Page]
    
    #if os(iOS)
    @ScaledMetric var sidebarWidth = 264
    #endif
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                detailPanel: $detailPanel,
                newFeedPageID: $newFeedPageID,
                newFeedURLString: $newFeedURLString,
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
                newFeedURLString = url.absoluteStringForNewFeed
                showingNewFeedSheet = true
            }
        }
        .task {
            if let detailPanelData {
                detailPanel = try? JSONDecoder().decode(DetailPanel.self, from: detailPanelData)
            }
            if let navigationData {
                navigationStore.restore(from: navigationData)
            }
            
            await BlocklistManager.initializeMissingContentRulesLists()

            CleanupUtility.upgradeBookmarks(context: modelContext)
            
            await performMaintenance()
            
            #if os(macOS)
            if !refreshManager.autoRefreshActive && refreshInterval.rawValue > 0 {
                refreshManager.startAutoRefresh(interval: TimeInterval(refreshInterval.rawValue))
            }
            #endif
        }
        #if os(iOS)
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                if let shortcutItem = QuickActionManager.shared.shortcutItem {
                    if shortcutItem.type == "InboxAction" {
                        detailPanel = .inbox
                    } else if shortcutItem.type == "TrendingAction" {
                        detailPanel = .trending
                    }
                    QuickActionManager.shared.shortcutItem = nil
                }
            default:
                break
            }
        }
        #endif
        .onChange(of: detailPanel) {
            detailPanelData = try? JSONEncoder().encode(detailPanel)
            navigationStore.path.removeLast(navigationStore.path.count)
        }
        .onChange(of: navigationStore.path) {
            navigationData = navigationStore.encoded()
        }
        .onChange(of: showingNewFeedSheet) {
            if showingNewFeedSheet {
                guard
                    newFeedPageID == nil,
                    case .page(let page) = detailPanel
                else { return }
                newFeedPageID = page.id?.uuidString
            }
        }
        .sheet(
            isPresented: $showingNewFeedSheet,
            onDismiss: {
                Task {
                    guard let feed = newFeed else { return }
                    await refreshManager.refresh(feed: feed)
                    
                    newFeed = nil
                    newFeedPageID = nil
                    newFeedURLString = ""
                }
            },
            content: {
                NewFeedSheet(
                    newFeed: $newFeed,
                    newFeedPageID: $newFeedPageID,
                    newFeedURLString: $newFeedURLString
                )
            }
        )
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
        
        withAnimation(completionCriteria: .removed) {
            if sourceType == "inbox" {
                detailPanel = .inbox
            } else if sourceType == "page" {
                if let page = pages.first(where: { $0.id == sourceID }) {
                    detailPanel = .page(page)
                }
            } else if sourceType == "feed" {
                if let feed = pages.feeds.first(where: { $0.id == sourceID }) {
                    detailPanel = .feed(feed)
                }
            }
        } completion: {
            if !navigationStore.path.isEmpty {
                navigationStore.path.removeLast(navigationStore.path.count)
            }
            
            // Restore item sub-detail view
            if let itemUUIDString = urlComponents.queryItems?.first(
                where: { $0.name == "item" }
            )?.value {
                let uuid = UUID(uuidString: itemUUIDString)
                let request = FetchDescriptor<Item>(
                    predicate: #Predicate<Item> { $0.id == uuid }
                )
                if let item = try? modelContext.fetch(request).first {
                    navigationStore.path.append(SubDetailPanel.item(item))
                }
            }
        }
    }
    
    private func performMaintenance() async {
        if let maintained = maintenanceTimestamp {
            let nextMaintenance = Date(timeIntervalSince1970: maintained) + 2 * 24 * 60 * 60
            if nextMaintenance > .now {
                Logger.main.info("""
                Next maintenance operation will be performed after \
                \(nextMaintenance.formatted(), privacy: .public)
                """)

                return
            }
        }
        
        await MaintenanceTask().execute()
    }
}
