//
//  ContentView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @Binding var activeProfileID: String?
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
    @SceneStorage("NavigationData") private var navigationData: Data?

    @StateObject private var navigationStore = NavigationStore(
        urlHandler: DefaultURLHandler(),
        activityHandler: DefaultActivityHandler()
    )
    
    var body: some View {
        NavigationStack(path: $navigationStore.path) {
            Group {
                switch contentSelection ?? .welcome {
                case .welcome:
                    WelcomeView(profile: profile)
                case .search:
                    SearchView(profile: profile, searchModel: searchModel)
                case .inbox:
                    InboxView(profile: profile, hideRead: $hideRead)
                case .trends:
                    TrendsView(profile: profile, hideRead: $hideRead)
                case .page(let uuidString):
                    if
                        let page = profile.pagesArray.firstMatchingUUIDString(uuidString: uuidString),
                        page.managedObjectContext != nil
                    {
                        PageView(page: page, hideRead: $hideRead)
                    } else {
                        StatusBoxView(message: Text("Page Deleted"), symbol: "slash.circle")
                    }
                case .settings:
                    SettingsView(
                        activeProfileID: $activeProfileID,
                        lastProfileID: $appProfileID,
                        uiStyle: $uiStyle,
                        autoRefreshEnabled: $autoRefreshEnabled,
                        autoRefreshCooldown: $autoRefreshCooldown,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        useInbuiltBrowser: $useInbuiltBrowser,
                        profile: profile
                    )
                }
            }
            .onChange(of: contentSelection) { _ in
                navigationStore.path.removeLast(navigationStore.path.count)
                navigationData = navigationStore.encoded()
            }
            .task {
                if let navigationData {
                    navigationStore.restore(from: navigationData)
                }
                for await _ in navigationStore.$path.values {
                    navigationData = navigationStore.encoded()
                }
            }
            .navigationDestination(for: DetailPanel.self) { detailPanel in
                switch detailPanel {
                case .feed(let uuidString):
                    if
                        let feed = profile.feedsArray.firstMatchingID(uuidString),
                        feed.managedObjectContext != nil
                    {
                        FeedView(feed: feed, hideRead: $hideRead)
                    } else {
                        StatusBoxView(message: Text("Feed Deleted"), symbol: "slash.circle")
                    }
                case .item(let uuidString):
                    if
                        let item = profile.previewItems.firstMatchingID(uuidString),
                        item.managedObjectContext != nil
                    {
                        ItemView(item: item)
                    } else {
                        StatusBoxView(message: Text("Item Deleted"), symbol: "slash.circle")
                    }
                case .trend(let uuidString):
                    if
                        let trend = profile.trends.firstMatchingID(uuidString),
                        trend.managedObjectContext != nil
                    {
                        TrendView(trend: trend, hideRead: $hideRead)
                    } else {
                        StatusBoxView(message: Text("Trend Deleted"), symbol: "slash.circle")
                    }
                }
            }
        }
    }
}
