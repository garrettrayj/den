//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DetailView: View {
    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?
    
    @StateObject private var navigationStore = NavigationStore()
    
    @SceneStorage("Navigation") private var navigationData: Data?
    
    var body: some View {
        NavigationStack(path: $navigationStore.path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .welcome:
                    Welcome(profile: profile)
                case .search(let query):
                    Search(profile: profile, query: query)
                case .inbox:
                    Inbox(profile: profile)
                case .trending:
                    Trending(profile: profile)
                case .page(let page):
                    PageView(
                        page: page,
                        profile: profile
                    )
                }
            }
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .feed(let feed):
                    FeedView(feed: feed)
                case .item(let item):
                    ItemView(item: item)
                case .trend(let trend):
                    TrendView(trend: trend)
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
        }
        .onChange(of: detailPanel) { _ in
            navigationStore.path.removeLast(navigationStore.path.count)
        }
    }
}
