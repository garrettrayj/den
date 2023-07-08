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

struct SplitView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    @Binding var userColorScheme: UserColorScheme
    @Binding var feedRefreshTimeout: Double

    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    @SceneStorage("ShowingNewFeedSheet") private var showingNewFeedSheet: Bool = false
    @SceneStorage("NewFeedWebAddress") private var newFeedWebAddress: String = ""
    @SceneStorage("NewFeedPageID") private var newFeedPageID: String?
    @SceneStorage("ShowingSettings") private var showingSettings: Bool = false
    @SceneStorage("DetailPanel") private var detailPanel: DetailPanel?

    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                detailPanel: $detailPanel,
                showingSettings: $showingSettings,
                feedRefreshTimeout: $feedRefreshTimeout
            )
            #if os(macOS)
            .navigationSplitViewColumnWidth(220)
            #else
            .navigationSplitViewColumnWidth(260 * dynamicTypeSize.layoutScalingFactor)
            .refreshable {
                if let profile = activeProfile, networkMonitor.isConnected {
                    await refreshManager.refresh(profile: profile, timeout: feedRefreshTimeout)
                }
            }
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel
            )
            .disabled(refreshManager.refreshing)
        }
        .tint(profile.tintColor)
        .environment(\.profileTint, profile.tintColor ?? .accentColor)
        .environment(\.useSystemBrowser, useSystemBrowser)
        .onOpenURL { url in
            if case .page(let page) = detailPanel {
                NewFeedUtility.showSheet(for: url.absoluteString, page: page)
            } else {
                NewFeedUtility.showSheet(for: url.absoluteString)
            }
        }
        .modifier(
            URLDropTargetModifier()
        )
        .onChange(of: activeProfile) { _ in
            detailPanel = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
            newFeedWebAddress = notification.userInfo?["urlString"] as? String ?? ""
            newFeedPageID = notification.userInfo?["pageID"] as? String
            showingNewFeedSheet = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            profile.objectWillChange.send()
            #if os(iOS)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            #endif
        }
        .sheet(isPresented: $showingNewFeedSheet) {
            NewFeedSheet(
                activeProfile: $activeProfile,
                webAddress: $newFeedWebAddress,
                initialPageID: $newFeedPageID,
                feedRefreshTimeout: $feedRefreshTimeout
            )
            .tint(profile.tintColor)
            .environmentObject(refreshManager)
        }
        .sheet(
            isPresented: $showingSettings,
            onDismiss: {
                if viewContext.hasChanges {
                    do {
                        try viewContext.save()
                    } catch {
                        CrashUtility.handleCriticalError(error as NSError)
                    }
                }
            }
        ) {
            SettingsSheet(
                profile: profile,
                activeProfile: $activeProfile,
                appProfileID: $appProfileID,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                feedRefreshTimeout: $feedRefreshTimeout,
                useSystemBrowser: $useSystemBrowser,
                userColorScheme: $userColorScheme
            )
        }
    }
}
