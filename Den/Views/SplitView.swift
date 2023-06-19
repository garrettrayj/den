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
    @Binding var detailPanel: DetailPanel?

    @State private var searchQuery: String = ""
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var showingSettings: Bool = false

    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                detailPanel: $detailPanel,
                searchQuery: $searchQuery,
                showingSettings: $showingSettings
            )
            // Column width is set by initial sidebar view
            #if os(iOS)
            .navigationSplitViewColumnWidth(264 * dynamicTypeSize.layoutScalingFactor)
            .refreshable {
                if let profile = activeProfile, networkMonitor.isConnected {
                    await refreshManager.refresh(profile: profile)
                }
            }
            #endif
        } detail: {
            DetailView(
                profile: profile,
                detailPanel: $detailPanel,
                searchQuery: $searchQuery
            )
        }
        .tint(profile.tintColor)
        .environment(\.profileTint, profile.tintColor ?? .accentColor)
        .environment(\.useSystemBrowser, useSystemBrowser)
        .onOpenURL { url in
            if case .page(let page) = detailPanel {
                SubscriptionUtility.showSubscribe(for: url.absoluteString, page: page)
            } else {
                SubscriptionUtility.showSubscribe(for: url.absoluteString)
            }
        }
        .modifier(
            URLDropTargetModifier()
        )
        .onChange(of: activeProfile) { _ in
            detailPanel = nil
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
            subscribeURLString = notification.userInfo?["urlString"] as? String ?? ""
            subscribePageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID
            showSubscribe = true
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
        .sheet(isPresented: $showSubscribe) {
            NewFeedSheet(
                initialPageObjectID: $subscribePageObjectID,
                initialURLString: $subscribeURLString,
                profile: activeProfile
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
                useSystemBrowser: $useSystemBrowser,
                userColorScheme: $userColorScheme
            )
        }
    }
}
