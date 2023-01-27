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
    @Binding var activeProfile: Profile?
    @Binding var sceneProfileID: String?
    @Binding var appProfileID: String?
    @Binding var contentSelection: ContentPanel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @SceneStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack {
            VStack {
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
                        StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
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
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                switch detailPanel {
                case .pageSettings(let page):
                    if page.managedObjectContext != nil {
                        PageSettingsView(page: page)
                    } else {
                        StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    }
                case .feed(let feed):
                    if feed.managedObjectContext != nil {
                        FeedView(feed: feed, hideRead: $hideRead)
                    } else {
                        StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    }
                case .feedSettings(let feed):
                    if feed.managedObjectContext != nil {
                        FeedSettingsView(feed: feed)
                    } else {
                        StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    }
                case .item(let item):
                    if item.managedObjectContext != nil {
                        ItemView(item: item)
                    } else {
                        StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                    }
                case .trend(let trend):
                    if trend.managedObjectContext != nil {
                        TrendView(trend: trend, hideRead: $hideRead)
                    } else {
                        StatusBoxView(message: Text("Trend Deleted"), symbol: "slash.circle")
                    }
                }
            }
            .navigationDestination(for: SettingsPanel.self) { settingsPanel in
                switch settingsPanel {
                case .profileSettings(let profile):
                    ProfileSettingsView(
                        activeProfile: $activeProfile,
                        sceneProfileID: $sceneProfileID,
                        appProfileID: $appProfileID,
                        profile: profile,
                        nameInput: profile.wrappedName
                    )
                case .importFeeds:
                    ImportView(profile: profile)
                case .exportFeeds:
                    ExportView(profile: profile)
                case .security:
                    SecurityView(profile: profile)
                }
            }
        }
    }
}
