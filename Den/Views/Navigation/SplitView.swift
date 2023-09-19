//
//  SplitView.swift
//  Den
//
//  Created by Garrett Johnson on 5/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI
import UniformTypeIdentifiers

struct SplitView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.userTint) private var userTint

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var showingNewProfileSheet: Bool

    let profiles: FetchedResults<Profile>
    let refreshProgress: Progress = Progress()

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var refreshing: Bool = false

    @StateObject private var navigationStore = NavigationStore()

    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?
    @SceneStorage("Navigation") private var navigationData: Data?

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                currentProfileID: $currentProfileID,
                detailPanel: $detailPanel,
                newFeedPageID: $newFeedPageID,
                newFeedWebAddress: $newFeedWebAddress,
                refreshing: $refreshing,
                showingNewFeedSheet: $showingNewFeedSheet,
                showingNewProfileSheet: $showingNewProfileSheet,
                profiles: profiles,
                refreshProgress: refreshProgress
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(min: 212, ideal: 212)
            #else
            .navigationSplitViewColumnWidth(272 * dynamicTypeSize.layoutScalingFactor)
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel,
                hideRead: $hideRead,
                refreshing: $refreshing,
                path: $navigationStore.path
            )
            #if os(iOS)
            .background(Color(.systemGroupedBackground))
            #endif
        }
        .tint(userTint)
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
                guard newFeedPageID == nil, case .page(let page) = detailPanel else { return }
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
