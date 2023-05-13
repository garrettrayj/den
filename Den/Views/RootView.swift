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
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var activeProfile: Profile?

    @State private var showCrashMessage = false
    @State private var searchQuery: String = ""
    @State private var contentSelection: DetailPanel?
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var columnVisibility: NavigationSplitViewVisibility = .doubleColumn

    @AppStorage("AutoRefreshEnabled") private var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") private var autoRefreshCooldown: Int = 30
    @AppStorage("UseInbuiltBrowser") private var useInbuiltBrowser: Bool = true
    @AppStorage("AutoRefreshDate") private var autoRefreshDate: Double = 0.0
    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                Sidebar(
                    profile: profile,
                    contentSelection: $contentSelection,
                    searchQuery: $searchQuery
                )
                #if !targetEnvironment(macCatalyst)
                .refreshable {
                    if networkMonitor.isConnected, let profile = activeProfile {
                        await refreshManager.refresh(profile: profile)
                    }
                }
                #endif
            } else {
                LoadProfile(
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID,
                    columnVisibility: $columnVisibility
                )
                // Column width is set by initial sidebar view
                #if targetEnvironment(macCatalyst)
                .navigationSplitViewColumnWidth(224)
                #else
                .navigationSplitViewColumnWidth(264 * dynamicTypeSize.layoutScalingFactor)
                #endif
            }
        } detail: {
            if let profile = activeProfile, profile.managedObjectContext != nil {
                DetailView(
                    profile: profile,
                    activeProfile: $activeProfile,
                    appProfileID: $appProfileID,
                    contentSelection: $contentSelection,
                    uiStyle: $uiStyle,
                    autoRefreshEnabled: $autoRefreshEnabled,
                    autoRefreshCooldown: $autoRefreshCooldown,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    useInbuiltBrowser: $useInbuiltBrowser,
                    searchQuery: $searchQuery
                )
            } else {
                ZStack {}
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(GroupedBackground())
            }
        }
        .environment(\.useInbuiltBrowser, useInbuiltBrowser)
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
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                if autoRefreshEnabled && (
                    autoRefreshDate == 0.0 ||
                    Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                ) {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        Task {
                            guard let profile = activeProfile else { return }
                            Logger.main.debug("Performing automatic refresh for profile: \(profile.wrappedName)")
                            await refreshManager.refresh(profile: profile)
                            autoRefreshDate = Date.now.timeIntervalSinceReferenceDate
                        }
                    }
                }
            default: break
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
            showCrashMessage = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
            subscribeURLString = notification.userInfo?["urlString"] as? String ?? ""
            subscribePageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID
            showSubscribe = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: activeProfile?.objectID)) { _ in
            Haptics.mediumImpactFeedbackGenerator.impactOccurred()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: activeProfile?.objectID)) { _ in
            activeProfile?.objectWillChange.send()
            Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
        }
        .sheet(isPresented: $showCrashMessage) {
            CrashMessage()
                .interactiveDismissDisabled()
        }
        .sheet(isPresented: $showSubscribe) {
            AddFeed(
                initialPageObjectID: $subscribePageObjectID,
                initialURLString: $subscribeURLString,
                profile: activeProfile
            )
            .environment(\.colorScheme, colorScheme)
            .environmentObject(refreshManager)
        }
        .scrollContentBackground(.hidden)
        .preferredColorScheme(ColorScheme(uiStyle))
        .onChange(of: uiStyle) { _ in
            // Update UI style override for system views, e.g., built-in Safari on iOS
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
        .task {
            // Set initial UI style override for system views, e.g., built-in Safari on iOS
            WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
        }
    }
}
