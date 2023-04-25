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
            Group {
                switch contentSelection ?? .welcome {
                case .welcome:
                    Welcome(profile: profile, refreshing: $refreshManager.refreshing)
                case .search:
                    Search(profile: profile, query: searchQuery, hideRead: $hideRead)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead, refreshing: $refreshManager.refreshing)
                case .trends:
                    Trending(profile: profile, hideRead: $hideRead, refreshing: $refreshManager.refreshing)
                case .page(let page):
                    if page.managedObjectContext != nil {
                        PageView(
                            page: page,
                            profile: profile,
                            hideRead: $hideRead,
                            refreshing: $refreshManager.refreshing
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
            .disabled(refreshManager.refreshing)
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                Group {
                    switch detailPanel {
                    case .pageSettings(let page):
                        PageSettings(page: page)
                    case .feed(let feed):
                        FeedView(
                            feed: feed,
                            profile: profile,
                            refreshing: $refreshManager.refreshing,
                            hideRead: $hideRead
                        )
                    case .feedSettings(let feed):
                        FeedSettings(feed: feed)
                    case .item(let item):
                        ItemView(item: item, profile: profile)
                    case .trend(let trend):
                        TrendView(
                            trend: trend,
                            profile: profile,
                            refreshing: $refreshManager.refreshing,
                            hideRead: $hideRead
                        )
                    }
                }
                .background(GroupedBackground())
                .disabled(refreshManager.refreshing)
            }
        }
    }
}
