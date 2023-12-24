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
    @Environment(\.minDetailColumnWidth) private var minDetailColumnWidth
    @Environment(\.userTint) private var userTint

    @ObservedObject var profile: Profile

    @Binding var currentProfileID: String?
    @Binding var userColorScheme: UserColorScheme
    @Binding var useSystemBrowser: Bool

    let profiles: [Profile]
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

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
                userColorScheme: $userColorScheme,
                useSystemBrowser: $useSystemBrowser,
                showingNewFeedSheet: $showingNewFeedSheet,
                profiles: profiles
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(220)
            #else
            .navigationSplitViewColumnWidth(280)
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel,
                hideRead: $hideRead,
                path: $navigationStore.path
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
        .onChange(of: profile) {
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
    }
}
