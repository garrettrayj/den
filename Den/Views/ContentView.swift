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

    @Binding var activeProfile: Profile?
    @Binding var sceneProfileID: String?
    @Binding var appProfileID: String?
    @Binding var contentSelection: ContentPanel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    let searchModel: SearchModel

    @SceneStorage("HideRead") private var hideRead: Bool = false

    @AppStorage("ContentSizeCategory") private var contentSizeCategory: UIContentSizeCategory = .unspecified

    var body: some View {
        NavigationStack {
            VStack {
                if let profile = activeProfile {
                    switch contentSelection ?? .welcome {
                    case .welcome:
                        WelcomeView(profile: profile)
                    case .search:
                        SearchView(profile: profile, searchModel: searchModel)
                    case .inbox:
                        InboxView(profile: profile, hideRead: $hideRead)
                    case .trends:
                        TrendsView(profile: profile, hideRead: $hideRead)
                    case .page(let page):
                        if page.managedObjectContext != nil {
                            PageView(page: page, hideRead: $hideRead)
                        } else {
                            SplashNoteView(title: Text("Page Deleted"))
                        }
                    case .settings:
                        SettingsView(
                            activeProfile: $activeProfile,
                            sceneProfileID: $sceneProfileID,
                            appProfileID: $appProfileID,
                            uiStyle: $uiStyle,
                            contentSizeCategory: $contentSizeCategory,
                            autoRefreshEnabled: $autoRefreshEnabled,
                            autoRefreshCooldown: $autoRefreshCooldown,
                            backgroundRefreshEnabled: $backgroundRefreshEnabled,
                            useInbuiltBrowser: $useInbuiltBrowser,
                            profile: profile
                        )
                    }
                } else {
                    SplashNoteView(title: Text("Profile Unavailable"))
                }
            }
            .environment(\.contentSizeCategory, contentSizeCategory)
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                Group {
                    switch detailPanel {
                    case .pageSettings(let page):
                        if page.managedObjectContext != nil {
                            PageSettingsView(page: page)
                        } else {
                            SplashNoteView(title: Text("Page Deleted"), symbol: "slash.circle")
                        }
                    case .feed(let feed):
                        if feed.managedObjectContext != nil {
                            FeedView(feed: feed, hideRead: $hideRead)
                        } else {
                            SplashNoteView(title: Text("Feed Deleted"), symbol: "slash.circle")
                        }
                    case .feedSettings(let feed):
                        if feed.managedObjectContext != nil {
                            FeedSettingsView(feed: feed)
                        } else {
                            SplashNoteView(title: Text("Feed Deleted"), symbol: "slash.circle")
                        }
                    case .item(let item):
                        if item.managedObjectContext != nil {
                            ItemView(item: item)
                        } else {
                            SplashNoteView(title: Text("Item Deleted"), symbol: "slash.circle")
                        }
                    case .trend(let trend):
                        if trend.managedObjectContext != nil {
                            TrendView(trend: trend, hideRead: $hideRead)
                        } else {
                            SplashNoteView(title: Text("Trend Deleted"), symbol: "slash.circle")
                        }
                    }
                }.environment(\.contentSizeCategory, contentSizeCategory)
            }
            .navigationDestination(for: SettingsPanel.self) { settingsPanel in
                switch settingsPanel {
                case .profileSettings(let profile):
                    ProfileSettingsView(
                        contentSelection: $contentSelection,
                        activeProfile: $activeProfile,
                        sceneProfileID: $sceneProfileID,
                        appProfileID: $appProfileID,
                        profile: profile,
                        nameInput: profile.wrappedName
                    )
                case .importFeeds:
                    if let profile = activeProfile {
                        ImportView(profile: profile)
                    } else {
                        SplashNoteView(title: Text("Import Unavailable"))
                    }
                case .exportFeeds:
                    if let profile = activeProfile {
                        ExportView(profile: profile)
                    } else {
                        SplashNoteView(title: Text("Export Unavailable"))
                    }
                case .security:
                    if let profile = activeProfile {
                        SecurityView(profile: profile)
                    } else {
                        SplashNoteView(title: Text("Security Check Unavailable"))
                    }
                }
            }
        }

    }
}
