//
//  RootView.swift
//  Den
//
//  Created by Garrett Johnson on 5/18/20.
//  Copyright © 2020 Garrett Johnson. All rights reserved.
//

import CoreData
import SwiftUI

struct RootView: View {
    @Environment(\.colorScheme) private var colorScheme: ColorScheme
    @Environment(\.persistentContainer) private var container

    @Binding var activeProfile: Profile?
    @Binding var refreshing: Bool
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var uiStyle: UIUserInterfaceStyle

    @StateObject private var searchModel = SearchModel()

    @State private var selection: Panel?
    @State private var path = NavigationPath()
    @State private var refreshProgress: Progress = Progress()
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""

    var body: some View {
        if showCrashMessage {
            CrashMessageView(message: crashMessage)
        } else if let profile = activeProfile {
            NavigationSplitView {
                SidebarView(
                    profile: profile,
                    activeProfile: $activeProfile,
                    selection: $selection,
                    refreshing: $refreshing,
                    refreshProgress: $refreshProgress,
                    searchModel: searchModel
                )
                .navigationSplitViewColumnWidth(268)
            } detail: {
                DetailView(
                    path: $path,
                    refreshing: $refreshing,
                    selection: $selection,
                    activeProfile: $activeProfile,
                    uiStyle: $uiStyle,
                    autoRefreshEnabled: $autoRefreshEnabled,
                    autoRefreshCooldown: $autoRefreshCooldown,
                    backgroundRefreshEnabled: $backgroundRefreshEnabled,
                    profile: profile,
                    searchModel: searchModel
                )
            }
            .onChange(of: selection) { _ in
                path.removeLast(path.count)
            }
            .onChange(of: uiStyle, perform: { _ in
                WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
            })
            .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
                Haptics.mediumImpactFeedbackGenerator.impactOccurred()
                self.refreshProgress.totalUnitCount = Int64(activeProfile?.feedsArray.count ?? 0)
                self.refreshProgress.completedUnitCount = 0
                self.refreshing = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                self.refreshProgress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
                self.refreshProgress.completedUnitCount += 1
            }
            .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
                self.refreshing = false
                profile.objectWillChange.send()
                Haptics.notificationFeedbackGenerator.notificationOccurred(.success)
            }
            .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
                subscribeURLString = notification.userInfo?["urlString"] as? String ?? ""
                subscribePageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID
                showSubscribe = true
            }
            .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
                showCrashMessage = true
            }
            .sheet(isPresented: $showSubscribe) {
                SubscribeView(
                    initialPageObjectID: $subscribePageObjectID,
                    initialURLString: $subscribeURLString,
                    profile: activeProfile
                )
                .environment(\.persistentContainer, container)
                .environment(\.colorScheme, colorScheme)
            }
        } else {
            VStack(spacing: 16) {
                Spacer()
                ProgressView()
                Text("Opening…")
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemGroupedBackground))
            .foregroundColor(Color.secondary)
        }
    }
}
