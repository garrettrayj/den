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

    @ObservedObject var profile: Profile

    @Binding var activeProfile: Profile?
    @Binding var appProfileID: String?
    @Binding var contentSelection: ContentPanel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool
    @Binding var refreshing: Bool
    @Binding var searchQuery: String

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                switch contentSelection ?? .welcome {
                case .welcome:
                    Welcome(profile: profile, refreshing: $refreshing)
                case .search:
                    SearchView(profile: profile, query: searchQuery)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead, refreshing: $refreshing)
                case .trends:
                    Trending(profile: profile, hideRead: $hideRead, refreshing: $refreshing)
                case .page(let page):
                    if page.managedObjectContext != nil {
                        PageView(
                            page: page,
                            profile: profile,
                            hideRead: $hideRead,
                            refreshing: $refreshing
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
            .background(Color(.systemGroupedBackground))
            .disabled(refreshing)
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                Group {
                    switch detailPanel {
                    case .pageSettings(let page):
                        if page.managedObjectContext != nil {
                            PageSettings(page: page)
                        } else {
                            SplashNote(title: "Page Deleted", symbol: "slash.circle")
                        }
                    case .feed(let feed):
                        if feed.managedObjectContext != nil {
                            FeedView(feed: feed, profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                        } else {
                            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
                        }
                    case .feedSettings(let feed):
                        if feed.managedObjectContext != nil {
                            FeedSettings(feed: feed)
                        } else {
                            SplashNote(title: "Feed Deleted", symbol: "slash.circle")
                        }
                    case .item(let item):
                        if item.managedObjectContext != nil {
                            ItemView(item: item, profile: profile)
                        } else {
                            SplashNote(title: "Item Deleted", symbol: "slash.circle")
                        }
                    case .trend(let trend):
                        if trend.managedObjectContext != nil {
                            TrendView(
                                trend: trend,
                                profile: profile,
                                refreshing: $refreshing,
                                hideRead: $hideRead
                            )
                        } else {
                            SplashNote(title: "Trend Deleted", symbol: "slash.circle")
                        }
                    }
                }
                .background(Color(.systemGroupedBackground))
                .disabled(refreshing)
            }
            .navigationDestination(for: SettingsPanel.self) { settingsPanel in
                Group {
                    switch settingsPanel {
                    case .profileSettings(let profile):
                        ProfileSettings(
                            profile: profile,
                            contentSelection: $contentSelection,
                            activeProfile: $activeProfile,
                            appProfileID: $appProfileID,
                            nameInput: profile.wrappedName,
                            tintSelection: profile.tint
                        )
                    case .importFeeds:
                        ImportView(profile: profile)
                    case .exportFeeds:
                        ExportView(profile: profile)
                    case .security:
                        SecurityView(profile: profile)
                    }
                }
                .background(Color(.systemGroupedBackground))
                .disabled(refreshing)
            }
        }
    }
}
