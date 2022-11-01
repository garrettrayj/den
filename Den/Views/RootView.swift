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
    @Environment(\.persistentContainer) private var persistentContainer
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @Binding var activeProfile: Profile?

    @StateObject private var searchModel = SearchModel()
    @StateObject private var haptics = Haptics()

    @State private var selection: Panel?
    @State private var path = NavigationPath()
    @State private var refreshing: Bool = false
    @State private var refreshProgress: Progress = Progress()
    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""
    @State private var profileUnreadCount: Int = 0

    @AppStorage("UIStyle") private var uiStyle = UIUserInterfaceStyle.unspecified

    var body: some View {
        Group {
            if showCrashMessage {
                CrashMessageView(message: crashMessage)
            } else if let profile = activeProfile {
                NavigationSplitView {
                    SidebarView(
                        profile: profile,
                        activeProfile: $activeProfile,
                        selection: $selection,
                        refreshing: $refreshing,
                        profileUnreadCount: $profileUnreadCount,
                        refreshProgress: refreshProgress,
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
                        profileUnreadCount: $profileUnreadCount,
                        profile: profile,
                        searchModel: searchModel                    )
                }
                .onAppear {
                    profileUnreadCount = profile.previewItems.unread().count
                    WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
                }
                .onChange(of: selection) { _ in
                    path.removeLast(path.count)
                }
                .onChange(of: uiStyle, perform: { _ in
                    WindowFinder.current()?.overrideUserInterfaceStyle = uiStyle
                })
                .onReceive(NotificationCenter.default.publisher(for: .itemStatus)) { notification in
                    guard
                        let profileObjectID = notification.userInfo?["profileObjectID"] as? NSManagedObjectID,
                        profileObjectID == profile.objectID,
                        let read = notification.userInfo?["read"] as? Bool
                    else {
                        return
                    }
                    profileUnreadCount += read ? -1 : 1
                }
                .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
                    haptics.mediumImpactFeedbackGenerator.impactOccurred()
                    self.refreshProgress.totalUnitCount = Int64(activeProfile?.feedsArray.count ?? 0)
                    self.refreshProgress.completedUnitCount = 0
                    self.refreshing = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                    self.refreshProgress.completedUnitCount += 1
                }
                .onReceive(NotificationCenter.default.publisher(for: .pagesRefreshed)) { _ in
                    self.refreshProgress.completedUnitCount += 1
                    self.profileUnreadCount = profile.previewItems.unread().count
                }
                .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
                    self.refreshing = false
                    profile.objectWillChange.send()
                    haptics.notificationFeedbackGenerator.notificationOccurred(.success)
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
                    .environment(\.persistentContainer, persistentContainer)
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
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .preferredColorScheme(ColorScheme(uiStyle))
        .environmentObject(haptics)
        .onAppear {
            if activeProfile == nil {
                activeProfile = ProfileManager.loadProfile(
                    context: viewContext,
                    profiles: profiles.map { $0 }
                )
            }
        }
    }
}
