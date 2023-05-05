//
//  SplitView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import CoreData
import OSLog
import SwiftUI

struct SplitView: View {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject private var networkMonitor: NetworkMonitor
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var uiStyle: UIUserInterfaceStyle

    @State private var searchQuery: String = ""
    @State private var contentSelection: ContentPanel?
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?

    @AppStorage("AutoRefreshEnabled") private var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") private var autoRefreshCooldown: Int = 30
    @AppStorage("UseInbuiltBrowser") private var useInbuiltBrowser: Bool = true
    @AppStorage("AutoRefreshDate") private var autoRefreshDate: Double = 0.0

    var body: some View {
        NavigationSplitView {
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
        } detail: {
            ContentView(
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
        .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
            subscribeURLString = notification.userInfo?["urlString"] as? String ?? ""
            subscribePageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID
            showSubscribe = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
            Haptics.mediumImpactFeedbackGenerator.impactOccurred()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            profile.objectWillChange.send()
            Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
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
        .tint(profile.tintColor)
        .scrollContentBackground(.hidden)
    }
}
