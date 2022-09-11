//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    @Binding var path: NavigationPath
    @Binding var refreshing: Bool
    @Binding var selection: Panel?
    @Binding var activeProfile: Profile?
    @Binding var uiStyle: UIUserInterfaceStyle

    @ObservedObject var profile: Profile

    let searchModel: SearchModel
    let profiles: FetchedResults<Profile>

    var body: some View {
        NavigationStack {
            switch selection ?? .welcome {
            case .welcome:
                WelcomeView(profile: profile)
            case .search:
                SearchView(profile: profile, searchModel: searchModel)
            case .allItems:
                AllItemsView(
                    profile: profile,
                    unreadCount: profile.previewItems.unread().count,
                    refreshing: $refreshing
                )
            case .trends:
                TrendsView(
                    profile: profile,
                    unreadCount: profile.trends.unread().count,
                    refreshing: $refreshing
                )
            case .page(let page):
                PageView(
                    page: page,
                    refreshing: $refreshing
                ).id(page.id)
            case .settings:
                SettingsView(activeProfile: $activeProfile, uiStyle: $uiStyle)
            }
        }
        #if targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .navigationDestination(for: DetailPanel.self) { detailPanel in
            switch detailPanel {
            case .trend(let trend):
                TrendView(
                    trend: trend,
                    unreadCount: trend.items.unread().count,
                    refreshing: $refreshing
                ).id(trend.id)
            case .feed(let feed):
                if let feed = feed {
                    FeedView(
                        feed: feed,
                        unreadCount: feed.feedData?.previewItems.unread().count ?? 0,
                        refreshing: $refreshing
                    ).id(feed.id)
                }
            case .pageSettings(let page):
                PageSettingsView(page: page).id(page.id)
            case .iconPicker(let page):
                IconPickerView(page: page).id(page.id)
            case .feedSettings(let feed):
                FeedSettingsView(feed: feed).id(feed.id)
            case .item(let item):
                ItemView(item: item).id(item.id)
            case .profile(let profile):
                ProfileView(activeProfile: $activeProfile, profile: profile).id(profile.id)
            case .importFeeds:
                ImportView(profile: profile)
            case .exportFeeds:
                ExportView(profile: profile)
            case .security:
                SecurityView(profile: profile)
            case .history:
                HistoryView(profile: profile)
            }
        }
    }
}
