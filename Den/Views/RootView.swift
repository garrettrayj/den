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
    @Environment(\.self) private var environment
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.openURL) private var openURL
    @Environment(\.scenePhase) private var scenePhase
    
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var appErrorMessage: String?
    @State private var showingAppErrorSheet = false
    @State private var detailPanel: DetailPanel?
    
    @StateObject private var navigationStore = NavigationStore()
    
    @SceneStorage("DetailPanel") private var detailPanelData: Data?
    @SceneStorage("Navigation") private var navigationData: Data?
    @SceneStorage("NewFeedPageObjectURL") private var newFeedPageObjectURL: URL?
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet = false
    
    @AppStorage("Maintained") private var maintenanceTimestamp: Double?
    @AppStorage("AccentColor") private var accentColor: AccentColor = .coral
    @AppStorage("UserColorScheme") private var userColorScheme: UserColorScheme = .system
    @AppStorage("RefreshInterval") private var refreshInterval: RefreshInterval = .zero
    @AppStorage("Viewer") private var viewer: ViewerOption = .builtInViewer
    
    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.userOrder, order: .forward),
        SortDescriptor(\.name, order: .forward)
    ])
    private var pages: FetchedResults<Page>
    
    @ScaledMetric var sidebarWidth = 264

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(detailPanel: $detailPanel, pages: pages)
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 180, ideal: 220, max: 280)
            #else
            // On iOS, sidebar width changes are appplied when app is relaunched.
            .navigationSplitViewColumnWidth(sidebarWidth)
            #endif
        } detail: {
            DetailView(detailPanel: $detailPanel, path: $navigationStore.path)
        }
        .background {
            // Buttons in background for keyboard shortcuts
            Group {
                NewFeedButton()
                NewPageButton()
            }
            .disabled(pages.isEmpty)
            .opacity(0)
        }
        #if os(macOS)
        .background(.background.opacity(colorScheme == .dark ? 1 : 0), ignoresSafeAreaEdges: .all)
        .background(.windowBackground.opacity(colorScheme == .dark ? 1 : 0), ignoresSafeAreaEdges: .all)
        #endif
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
        .onOpenURL { url in
            if url.scheme == "den+widget" {
                openWidgetURL(url: url)
            } else {
                if case .page(let objectURL) = detailPanel {
                    newFeedPageObjectURL = objectURL
                }
                newFeedWebAddress = url.absoluteStringForNewFeed
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

            CleanupUtility.upgradeBookmarks(context: viewContext)
            
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
                    newFeedPageObjectURL == nil,
                    case .page(let objectURL) = detailPanel
                else { return }
                newFeedPageObjectURL = objectURL
            } else {
                newFeedPageObjectURL = nil
                newFeedWebAddress = ""
            }
        }
        .sheet(isPresented: $showingNewFeedSheet) {
            NewFeedSheet(webAddress: $newFeedWebAddress, initialPageObjectURL: $newFeedPageObjectURL)
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
        .tint(accentColor.color)
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
                    detailPanel = .page(page.objectID.uriRepresentation())
                }
            } else if sourceType == "feed" {
                if let feed = pages.flatMap({ $0.feedsArray }).first(where: { $0.id == sourceID }) {
                    detailPanel = .feed(feed.objectID.uriRepresentation())
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
                    goToItem(item: item)
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
        
        await MaintenanceTask.execute()
    }
    
    private func goToItem(item: Item) {
        #if os(macOS)
        if viewer == .webBrowser {
            guard let url = item.link else { return }
            openURL(url)
            HistoryUtility.markItemRead(context: viewContext, item: item)
        } else {
            navigationStore.path.append(SubDetailPanel.item(item.objectID.uriRepresentation()))
        }
        #else
        if viewer == .webBrowser {
            guard let url = item.link else { return }
            openURL(url)
            HistoryUtility.markItemRead(context: viewContext, item: item)
        } else if viewer == .safariView {
            guard let url = item.link else { return }
            InAppSafari.open(
                url: url,
                environment: environment,
                accentColor: accentColor,
                entersReaderIfAvailable: item.feedData?.feed?.readerMode ?? false
            )
            HistoryUtility.markItemRead(context: viewContext, item: item)
        } else {
            navigationStore.path.append(SubDetailPanel.item(item.objectID.uriRepresentation()))
        }
        #endif
    }
}
