//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DetailView: View {
    static let selectionUserActivityType = "net.devsci.den.select-panel"
    
    @Binding var activeProfileID: String?
    @Binding var lastProfileID: String?
    @Binding var selection: Panel?
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var autoRefreshEnabled: Bool
    @Binding var autoRefreshCooldown: Int
    @Binding var backgroundRefreshEnabled: Bool
    @Binding var useInbuiltBrowser: Bool

    @ObservedObject var profile: Profile

    let searchModel: SearchModel
    
    @StateObject private var navigationStore = NavigationStore(
        urlHandler: DefaultURLHandler(),
        activityHandler: DefaultActivityHandler()
    )
        
    @SceneStorage("NavigationData") private var navigationData: Data?
    @SceneStorage("HideRead") private var hideRead: Bool = false
    
    var body: some View {
        NavigationStack(path: $navigationStore.path) {
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
                        lastProfileID: $lastProfileID,
                        uiStyle: $uiStyle,
                        autoRefreshEnabled: $autoRefreshEnabled,
                        autoRefreshCooldown: $autoRefreshCooldown,
                        backgroundRefreshEnabled: $backgroundRefreshEnabled,
                        useInbuiltBrowser: $useInbuiltBrowser,
                        profile: profile
                    )
                }
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
                }
            }
            .userActivity(
                DetailView.selectionUserActivityType,
                isActive: true
            ) { userActivity in
                guard let panel = selection else { return }
                print("UPDATING USER ACTIVITY: \(panel)")
                describeUserActivity(userActivity, panel: panel)
            }
        }
    }
    
    func describeUserActivity(_ userActivity: NSUserActivity, panel: Panel) {
        userActivity.title = "ShowPanel"
        userActivity.isEligibleForHandoff = true
        userActivity.isEligibleForSearch = true
        userActivity.targetContentIdentifier = selection.debugDescription
        try? userActivity.setTypedPayload(panel)
    }
}
