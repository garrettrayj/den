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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var appProfileID: String?
    @Binding var uiStyle: UIUserInterfaceStyle

    @StateObject private var searchModel = SearchModel()

    @State private var contentSelection: ContentPanel?
    @State private var refreshing: Bool = false
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?

    @AppStorage("AutoRefreshEnabled") private var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") private var autoRefreshCooldown: Int = 30
    @AppStorage("UseInbuiltBrowser") private var useInbuiltBrowser: Bool = true

    @SceneStorage("ActiveProfileID") private var sceneProfileID: String?
    @SceneStorage("AutoRefreshDate") private var autoRefreshDate: Double = 0.0

    var body: some View {
        NavigationSplitView {
            SidebarView(
                searchModel: searchModel,
                profile: profile,
                activeProfile: $activeProfile,
                contentSelection: $contentSelection,
                refreshing: $refreshing
            )
            #if targetEnvironment(macCatalyst)
            .navigationSplitViewColumnWidth(240)
            #else
            .refreshable {
                if !refreshing, let profile = activeProfile {
                    await RefreshUtility.refresh(profile: profile)
                }
            }
            .navigationSplitViewColumnWidth(240 * dynamicTypeSize.fontScale)
            #endif
        } detail: {
            ContentView(
                profile: profile,
                activeProfile: $activeProfile,
                sceneProfileID: $sceneProfileID,
                appProfileID: $appProfileID,
                contentSelection: $contentSelection,
                uiStyle: $uiStyle,
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                useInbuiltBrowser: $useInbuiltBrowser,
                searchModel: searchModel
            )
            .disabled(refreshing)
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
        .onChange(of: profile.tint) { _ in
            updateAppIcon()
        }
        .onChange(of: activeProfile) { _ in
            updateAppIcon()
        }
        .onChange(of: uiStyle) { _ in
            updateAppIcon()
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
            case .active:
                if autoRefreshEnabled && !refreshing && (
                    autoRefreshDate == 0.0 ||
                    Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                ) {
                    Logger.main.debug("Performing automatic refresh")
                    Task {
                        guard !refreshing, let profile = activeProfile else { return }
                        await RefreshUtility.refresh(profile: profile)
                        autoRefreshDate = Date.now.timeIntervalSinceReferenceDate
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
            refreshing = true
            Haptics.mediumImpactFeedbackGenerator.impactOccurred()
        }
        .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
            refreshing = false
            profile.objectWillChange.send()
            Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
        }
        .sheet(isPresented: $showSubscribe) {
            SubscribeView(
                initialPageObjectID: $subscribePageObjectID,
                initialURLString: $subscribeURLString,
                profile: activeProfile
            )
            .environment(\.colorScheme, colorScheme)
        }
    }

    private func updateAppIcon() {
        let iconName = "AppIcon-\(uiStyle.name ?? "Light")-\(activeProfile?.tint ?? "Default")"
        if iconName != UIApplication.shared.alternateIconName {
            UIApplication.shared.setAlternateIconName(iconName) { error in
                if let error = error {
                    Logger.main.warning("Alternate icon error \(iconName): \(error.localizedDescription)")
                } else {
                    Logger.main.info("Successfully set alternate icon: \(iconName)")
                }
            }
        }
    }
}
