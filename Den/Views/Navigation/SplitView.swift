//
//  SplitView.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/23.
//  Copyright © 2023 Garrett Johnson
//

import CoreData
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct SplitView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth
    @Environment(\.userTint) private var userTint

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    let profiles: [Profile]
    let refreshProgress: Progress = Progress()

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var refreshing: Bool = false

    @StateObject private var navigationStore = NavigationStore()

    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("RawDetailPanel") private var rawDetailPanel: String?
    @SceneStorage("Navigation") private var navigationData: Data?

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        let detailPanelBinding = Binding<DetailPanel?>(
            get: {
                guard let rawDetailPanel = rawDetailPanel else { return nil }
                return DetailPanel(rawValue: rawDetailPanel)
            },
            set: {
                if let newValue = $0 {
                    self.rawDetailPanel = newValue.rawValue
                } else {
                    self.rawDetailPanel = nil
                }
            }
        )
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: detailPanelBinding,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                refreshing: $refreshing,
                userColorScheme: $userColorScheme,
                useSystemBrowser: $useSystemBrowser,
                showingNewFeedSheet: $showingNewFeedSheet,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(220)
            #else
            .navigationSplitViewColumnWidth(264)
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: detailPanelBinding,
                hideRead: $hideRead,
                refreshing: $refreshing,
                path: $navigationStore.path
            )
            .navigationSplitViewColumnWidth(min: minDetailColumnWidth, ideal: 600)
            #if os(iOS)
            .toolbarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground), ignoresSafeAreaEdges: .all)
            #endif
        }
        .tint(userTint)
        .handlesExternalEvents(preferring: ["*"], allowing: ["*"])
        .onOpenURL { url in
            if case .page(let page) = detailPanelBinding.wrappedValue {
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
            detailPanelBinding.wrappedValue = nil
        }
        .onChange(of: rawDetailPanel) {
            navigationStore.path.removeLast(navigationStore.path.count)
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
            profile.pagesArray.forEach { $0.objectWillChange.send() }
        }
        .sensoryFeedback(trigger: refreshing) { _, newValue in
            if newValue == true {
                return .start
            } else {
                return .success
            }
        }
        .onChange(of: showingNewFeedSheet) {
            if showingNewFeedSheet {
                guard
                    newFeedPageID == nil,
                    case .page(let page) = detailPanelBinding.wrappedValue
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
    }
}
