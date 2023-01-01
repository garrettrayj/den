//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 12/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import CoreData
import OSLog
import SwiftUI

struct ContentView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.scenePhase) private var scenePhase

    @ObservedObject var profile: Profile

    @Binding var backgroundRefreshEnabled: Bool
    @Binding var lastProfileID: String?
    @Binding var uiStyle: UIUserInterfaceStyle

    @StateObject private var searchModel = SearchModel()

    @State private var refreshing: Bool = false
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?

    @AppStorage("AutoRefreshEnabled") var autoRefreshEnabled: Bool = false
    @AppStorage("AutoRefreshCooldown") var autoRefreshCooldown: Int = 30
    @AppStorage("UseInbuiltBrowser") var useInbuiltBrowser: Bool = true

    @SceneStorage("ActiveProfileID") private var activeProfileID: String?
    @SceneStorage("AutoRefreshDate") private var autoRefreshDate: Double = 0.0
    @SceneStorage("PanelSelection") private var selection: RootPanel?

    var body: some View {
        NavigationSplitView {
            SidebarView(
                profile: profile,
                searchModel: searchModel,
                selection: $selection,
                refreshing: $refreshing
            )
            #if targetEnvironment(macCatalyst)
            .navigationSplitViewColumnWidth(240)
            #else
            .navigationSplitViewColumnWidth(280)
            #endif
            .disabled(refreshing)
        } detail: {
            DetailView(
                activeProfileID: $activeProfileID,
                lastProfileID: $lastProfileID,
                selection: $selection,
                uiStyle: $uiStyle,
                autoRefreshEnabled: $autoRefreshEnabled,
                autoRefreshCooldown: $autoRefreshCooldown,
                backgroundRefreshEnabled: $backgroundRefreshEnabled,
                useInbuiltBrowser: $useInbuiltBrowser,
                profile: profile,
                searchModel: searchModel
            )
            .disabled(refreshing)
        }
        .environment(\.useInbuiltBrowser, useInbuiltBrowser)
        .onOpenURL { url in
            if case .page(let uuidString) = selection {
                let page = profile.pagesArray.firstMatchingUUIDString(uuidString: uuidString)
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
                if autoRefreshEnabled && !refreshing && (
                    autoRefreshDate == 0.0 ||
                    Date(timeIntervalSinceReferenceDate: autoRefreshDate) < .now - Double(autoRefreshCooldown) * 60
                ) {
                    Logger.main.debug("Performing automatic refresh")
                    Task {
                        guard !refreshing else { return }
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
                profile: profile
            )
            .environment(\.colorScheme, colorScheme)
        }
    }
}
