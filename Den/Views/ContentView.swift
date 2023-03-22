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
    @Binding var sceneProfileID: String?
    @Binding var appProfileID: String?
    @Binding var contentSelection: ContentPanel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool
    @Binding var refreshing: Bool

    let searchModel: SearchModel

    @SceneStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                switch contentSelection ?? .welcome {
                case .welcome:
                    WelcomeView(profile: profile, refreshing: $refreshing)
                case .search:
                    SearchView(profile: profile, searchModel: searchModel)
                case .inbox:
                    InboxView(profile: profile, hideRead: $hideRead, refreshing: $refreshing)
                case .trends:
                    TrendsView(profile: profile, hideRead: $hideRead, refreshing: $refreshing)
                case .page(let page):
                    if page.managedObjectContext != nil {
                        PageView(
                            page: page,
                            profile: profile,
                            hideRead: $hideRead,
                            refreshing: $refreshing
                        )
                    } else {
                        SplashNoteView(title: "Page Deleted")
                    }
                case .settings:
                    SettingsView(
                        activeProfile: $activeProfile,
                        sceneProfileID: $sceneProfileID,
                        appProfileID: $appProfileID,
                        uiStyle: $uiStyle,
                        autoRefreshEnabled: $autoRefreshEnabled,
                        autoRefreshCooldown: $autoRefreshCooldown,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        useInbuiltBrowser: $useInbuiltBrowser,
                        profile: profile
                    )
                }
            }
            .modifier(BaseBackgroundModifier())
            .disabled(refreshing)
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                Group {
                    switch detailPanel {
                    case .pageSettings(let page):
                        if page.managedObjectContext != nil {
                            PageSettingsView(page: page)
                        } else {
                            SplashNoteView(title: "Page Deleted", symbol: "slash.circle")
                        }
                    case .feed(let feed):
                        if feed.managedObjectContext != nil {
                            FeedView(feed: feed, profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                        } else {
                            SplashNoteView(title: "Feed Deleted", symbol: "slash.circle")
                        }
                    case .feedSettings(let feed):
                        if feed.managedObjectContext != nil {
                            FeedSettingsView(feed: feed)
                        } else {
                            SplashNoteView(title: "Feed Deleted", symbol: "slash.circle")
                        }
                    case .item(let item):
                        if item.managedObjectContext != nil {
                            ItemView(item: item, profile: profile)
                        } else {
                            SplashNoteView(title: "Item Deleted", symbol: "slash.circle")
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
                            SplashNoteView(title: "Trend Deleted", symbol: "slash.circle")
                        }
                    }
                }
                .modifier(BaseBackgroundModifier())
                .disabled(refreshing)
            }
            .navigationDestination(for: SettingsPanel.self) { settingsPanel in
                Group {
                    switch settingsPanel {
                    case .profileSettings(let profile):
                        ProfileSettingsView(
                            contentSelection: $contentSelection,
                            activeProfile: $activeProfile,
                            sceneProfileID: $sceneProfileID,
                            appProfileID: $appProfileID,
                            profile: profile,
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
                .modifier(BaseBackgroundModifier())
                .disabled(refreshing)
            }
        }
    }
}
