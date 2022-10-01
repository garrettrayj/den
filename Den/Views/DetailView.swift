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
    @Binding var hapticsEnabled: Bool
    @Binding var profileUnreadCount: Int

    @ObservedObject var profile: Profile

    let searchModel: SearchModel
    let profiles: FetchedResults<Profile>

    @AppStorage("hideRead") var hideRead = false

    var body: some View {
        NavigationStack {
            Group {
                switch selection ?? .welcome {
                case .welcome:
                    WelcomeView(profile: profile)
                case .search:
                    SearchView(profile: profile, searchModel: searchModel)
                case .allItems:
                    AllItemsView(
                        profile: profile,
                        unreadCount: $profileUnreadCount,
                        hideRead: $hideRead,
                        refreshing: $refreshing
                    )
                case .trends:
                    TrendsView(
                        profile: profile,
                        unreadCount: profile.trends.unread().count,
                        hideRead: $hideRead,
                        refreshing: $refreshing
                    )
                case .page(let page):
                    PageView(
                        page: page,
                        hideRead: $hideRead,
                        refreshing: $refreshing
                    ).id(page.id)
                case .settings:
                    SettingsView(
                        activeProfile: $activeProfile,
                        uiStyle: $uiStyle,
                        hapticsEnabled: $hapticsEnabled
                    )
                }
            }
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                switch detailPanel {
                case .trend(let trend):
                    TrendView(
                        trend: trend,
                        unreadCount: trend.items.unread().count,
                        hideRead: $hideRead,
                        refreshing: $refreshing
                    ).id(trend.id)
                case .feed(let feed):
                    if let feed = feed {
                        FeedView(
                            feed: feed,
                            unreadCount: feed.feedData?.previewItems.unread().count ?? 0,
                            hideRead: $hideRead,
                            refreshing: $refreshing
                        ).id(feed.id)
                    }
                case .pageSettings(let page):
                    PageSettingsView(page: page).id(page.id)
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
        #if targetEnvironment(macCatalyst)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
