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
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?
    @Binding var userColorScheme: UserColorScheme
    @Binding var contentSelection: DetailPanel?

    @State private var searchQuery: String = ""
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State private var showingSettings: Bool = false

    @AppStorage("UseSystemBrowser") private var useSystemBrowser: Bool = false
    @AppStorage("AutoRefreshDate") private var autoRefreshDate: Double = 0.0

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(
                profile: profile,
                contentSelection: $contentSelection,
                searchQuery: $searchQuery,
                showingSettings: $showingSettings
            )
            // Column width is set by initial sidebar view
            #if os(macOS)
            .navigationSplitViewColumnWidth(224)
            #else
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
                activeProfile: $activeProfile,
                appProfileID: $appProfileID,
                contentSelection: $contentSelection,
                searchQuery: $searchQuery
            )
        }
        .tint(profile.tintColor)
        .environment(\.useSystemBrowser, useSystemBrowser)
        .onOpenURL { url in
            if case .page(let page) = contentSelection {
                SubscriptionUtility.showSubscribe(for: url.absoluteString, page: page)
            } else {
                SubscriptionUtility.showSubscribe(for: url.absoluteString)
            }
        }
        .modifier(
            URLDropTargetModifier()
        )
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
            AddFeed(
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
