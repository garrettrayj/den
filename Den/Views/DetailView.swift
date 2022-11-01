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
    @Binding var profileUnreadCount: Int

    @ObservedObject var profile: Profile

    let searchModel: SearchModel

    @AppStorage("hideRead") private var hideRead = false

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
                        profile: profile
                    )
                }
            }
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                switch detailPanel {
                case .feed(let feed):
                    if let feed = feed {
                        FeedView(
                            feed: feed,
                            hideRead: $hideRead,
                            refreshing: $refreshing
                        ).id(feed.id)
                    }
                case .item(let item):
                    ItemView(item: item).id(item.id)
                }
            }
        }
    }
}
