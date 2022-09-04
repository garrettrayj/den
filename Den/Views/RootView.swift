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
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(sortDescriptors: [SortDescriptor(\.name, order: .forward)])
    private var profiles: FetchedResults<Profile>

    @Binding var activeProfile: Profile?

    let persistentContainer: NSPersistentContainer
    let refreshProgress: Progress = Progress()

    @State private var selection: Panel?
    @State private var path = NavigationPath()
    @State private var refreshing: Bool = false
    @State private var searchInput: String = ""

    @State private var showSubscribe = false
    @State private var subscribeURLString: String = ""
    @State private var subscribePageObjectID: NSManagedObjectID?
    @State private var showCrashMessage = false
    @State private var crashMessage: String = ""

    var body: some View {
        Group {
            if showCrashMessage {
                CrashMessageView(message: crashMessage)
            } else if let profile = activeProfile {
                NavigationSplitView {
                    SidebarView(
                        profile: profile,
                        selection: $selection,
                        refreshing: $refreshing,
                        searchInput: $searchInput,
                        persistentContainer: persistentContainer,
                        refreshProgress: refreshProgress
                    )
                } detail: {
                    DetailColumn(
                        path: $path,
                        refreshing: $refreshing,
                        searchInput: $searchInput,
                        selection: $selection,
                        activeProfile: $activeProfile,
                        profile: profile,
                        profiles: profiles
                    )
                }
                .onChange(of: selection) { _ in
                    path.removeLast(path.count)
                }
                .onReceive(NotificationCenter.default.publisher(for: .refreshStarted, object: profile.objectID)) { _ in
                    self.refreshProgress.totalUnitCount = self.refreshUnits
                    self.refreshProgress.completedUnitCount = 0
                    self.refreshing = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .refreshFinished, object: profile.objectID)) { _ in
                    self.refreshing = false
                }
                .onReceive(NotificationCenter.default.publisher(for: .feedRefreshed)) { _ in
                    self.refreshProgress.completedUnitCount += 1
                }
                .onReceive(NotificationCenter.default.publisher(for: .showSubscribe, object: nil)) { notification in
                    if let urlString = notification.userInfo?["urlString"] as? String {
                        subscribeURLString = urlString
                    }
                    if let pageObjectID = notification.userInfo?["pageObjectID"] as? NSManagedObjectID {
                        subscribePageObjectID = pageObjectID
                    }
                    showSubscribe = true
                }
                .onReceive(NotificationCenter.default.publisher(for: .showCrashMessage, object: nil)) { _ in
                    showCrashMessage = true
                }
                .sheet(isPresented: $showSubscribe) {
                    SubscribeView(
                        initialPageObjectID: $subscribePageObjectID,
                        initialURLString: $subscribeURLString,
                        profile: activeProfile,
                        persistentContainer: persistentContainer
                    ).environment(\.colorScheme, colorScheme)
                }
            } else {
                ProfileNotAvailableView()
            }
        }
        .onAppear {
            if activeProfile == nil {
                activeProfile = ProfileManager.loadProfile(
                    context: viewContext,
                    profiles: profiles.map { $0 }
                )
            }
        }

    }

    private var refreshUnits: Int64 {
        // Number
        Int64(activeProfile?.feedsArray.count ?? -1) + 1
    }
}
