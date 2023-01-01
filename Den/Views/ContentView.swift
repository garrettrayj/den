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
    @Binding var apexSelection: ApexPanel?
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
                switch apexSelection ?? .welcome {
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
            .navigationDestination(for: DetailPanel.self) { detailPanel in
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
                case .trend(let trend):
                    if trend.managedObjectContext == nil {
                        StatusBoxView(message: Text("Trend Deleted"), symbol: "slash.circle")
                    } else {
                        TrendView(trend: trend, hideRead: $hideRead)
                    }
                }
            }
        }
    }
}
