//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

enum DetailPanel: Hashable {
    case trend(Trend.ID)
    case feed(Feed.ID)
    case pageSettings(Page.ID)
    case iconPicker(Page.ID)
    case feedSettings(Feed.ID)
    case item(Item.ID)
    case profile(Profile.ID)
    case importFeeds
    case exportFeeds
    case security
    case history
}

struct DetailColumn: View {
    @Binding var path: NavigationPath
    @Binding var refreshing: Bool
    @Binding var searchInput: String
    @Binding var selection: Panel?
    @Binding var activeProfile: Profile?
    @ObservedObject var profile: Profile

    let profiles: FetchedResults<Profile>

    var body: some View {
        NavigationStack {
            switch selection ?? .welcome {
            case .welcome:
                WelcomeView().toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        Text("\(profile.displayName)").font(.caption)
                    }
                }
            case .search:
                SearchView(profile: profile, query: $searchInput)
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
            case .page(let id):
                if let page = profile.pagesArray.first(where: {$0.id == id}) {
                    PageView(
                        page: page,
                        unreadCount: page.previewItems.unread().count,
                        refreshing: $refreshing
                    ).id(id)
                }
            case .settings:
                SettingsView(activeProfile: $activeProfile)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: DetailPanel.self) { detailPanel in
            switch detailPanel {
            case .trend(let id):
                if let trend = profile.trends.first(where: {$0.id == id}) {
                    TrendView(
                        trend: trend,
                        unreadCount: trend.items.unread().count,
                        refreshing: $refreshing
                    ).id(id)
                }
            case .feed(let id):
                if let feed = profile.feedsArray.first(where: {$0.id == id}) {
                    FeedView(
                        feed: feed,
                        unreadCount: feed.feedData?.previewItems.unread().count ?? 0,
                        refreshing: $refreshing
                    ).id(id)
                }
            case .pageSettings(let id):
                if let page = profile.pagesArray.first(where: {$0.id == id}) {
                    PageSettingsView(page: page).id(id)
                }
            case .iconPicker(let id):
                if let page = profile.pagesArray.first(where: {$0.id == id}) {
                    IconPickerView(page: page).id(id)
                }
            case .feedSettings(let id):
                if let feed = profile.feedsArray.first(where: {$0.id == id}) {
                    FeedSettingsView(feed: feed).id(id)
                }
            case .item(let id):
                if let item = profile.previewItems.first(where: {$0.id == id}) {
                    ItemView(item: item).id(id)
                }
            case .profile(let id):
                if let profile = profiles.first(where: {$0.id == id}) {
                    ProfileView(activeProfile: $activeProfile, profile: profile).id(id)
                }
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
