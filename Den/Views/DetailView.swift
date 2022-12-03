//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    @Binding var activeProfileID: String?
    @Binding var refreshing: Bool
    @Binding var selection: Panel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool

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
                case .inbox:
                    InboxView(profile: profile, hideRead: $hideRead)
                case .trends:
                    TrendsView(profile: profile, hideRead: $hideRead)
                case .page(let page):
                    if page.managedObjectContext == nil {
                        StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    } else {
                        PageView(page: page, hideRead: $hideRead)
                    }
                case .settings:
                    SettingsView(
                        activeProfileID: $activeProfileID,
                        uiStyle: $uiStyle,
                        autoRefreshEnabled: $autoRefreshEnabled,
                        autoRefreshCooldown: $autoRefreshCooldown,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        profile: profile
                    )
                }
            }
            .disabled(refreshing)
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                Group {
                    switch detailPanel {
                    case .feed(let feed):
                        if feed.managedObjectContext == nil {
                            StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                        } else {
                            FeedView(feed: feed, hideRead: $hideRead)
                        }
                    case .item(let item):
                        if item.managedObjectContext == nil {
                            StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                        } else {
                            ItemView(item: item)
                        }
                    case .pageSettings(let page):
                        if page.managedObjectContext == nil {
                            StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                        } else {
                            PageSettingsView(page: page)
                        }
                    case .feedSettings(let feed):
                        if feed.managedObjectContext == nil {
                            StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                        } else {
                            FeedSettingsView(feed: feed)
                        }
                    case .trend(let trend):
                        if trend.managedObjectContext == nil {
                            StatusBoxView(message: Text("Trend Deleted"), symbol: "slash.circle")
                        } else {
                            TrendView(trend: trend, hideRead: $hideRead)
                        }
                    }
                }.disabled(refreshing)
            }
        }
    }
}
