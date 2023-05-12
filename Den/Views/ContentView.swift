//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @EnvironmentObject private var refreshManager: RefreshManager

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var contentSelection: ContentPanel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool
    @Binding var searchQuery: String

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                switch contentSelection ?? .welcome {
                case .welcome:
                    Welcome(profile: profile, refreshing: $refreshManager.refreshing)
                case .search:
                    Search(profile: profile, hideRead: $hideRead, query: searchQuery)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead)
                case .page(let page):
                    if page.managedObjectContext != nil {
                        PageView(
                            page: page,
                            profile: profile,
                            hideRead: $hideRead
                        )
                    } else {
                        SplashNote(title: "Page Deleted")
                    }
                case .settings:
                    SettingsView(
                        profile: profile,
                        activeProfile: $activeProfile,
                        appProfileID: $appProfileID,
                        uiStyle: $uiStyle,
                        autoRefreshEnabled: $autoRefreshEnabled,
                        autoRefreshCooldown: $autoRefreshCooldown,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        useInbuiltBrowser: $useInbuiltBrowser
                    )
                }
            }
            .background(GroupedBackground())
            .tint(profile.tintColor)
            .disabled(refreshManager.refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                ZStack {
                    switch panel {
                    case .feed(let feed):
                        FeedView(
                            feed: feed,
                            profile: profile,
                            hideRead: $hideRead
                        )
                    case .item(let item):
                        if let feed = item.feedData?.feed {
                            ItemView(item: item, feed: feed, profile: profile)
                        }
                    case .trend(let trend):
                        TrendView(trend: trend, profile: profile, hideRead: $hideRead)
                    case .pageSettings(let page):
                        PageSettings(page: page)
                    case .feedSettings(let feed):
                        FeedSettings(feed: feed)
                    case .profileSettings(let profile):
                        ProfileSettings(
                            profile: profile,
                            activeProfile: $activeProfile,
                            appProfileID: $appProfileID,
                            tintSelection: profile.tint
                        )
                    case .importFeeds(let profile):
                        ImportView(profile: profile)
                    case .exportFeeds(let profile):
                        ExportView(profile: profile)
                    case .security(let profile):
                        SecurityView(profile: profile)
                    }
                }
                .background(GroupedBackground())
                .tint(profile.tintColor)
                .disabled(refreshManager.refreshing)
            }
        }
    }
}
