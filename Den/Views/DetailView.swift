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
    @EnvironmentObject private var refreshManager: RefreshManager
    
    @ObservedObject var profile: Profile

    @Binding var detailPanel: DetailPanel?

    @StateObject private var navigationStore = NavigationStore()

    @SceneStorage("Navigation") private var navigationData: Data?

    var body: some View {
        NavigationStack(path: $navigationStore.path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .diagnostics:
                    DiagnosticsTable(profile: profile)
                case .inbox:
                    Inbox(profile: profile)
                case .page(let page):
                    PageView(page: page, profile: profile)
                case .search(let query):
                    Search(profile: profile, query: query)
                case .trending:
                    Trending(profile: profile)
                case .welcome:
                    Welcome(profile: profile)
                }
            }
            .disabled(refreshManager.refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                ZStack {
                    switch panel {
                    case .feed(let feed):
                        FeedView(feed: feed)
                    case .item(let item):
                        ItemView(item: item)
                    case .trend(let trend):
                        TrendView(trend: trend)
                    }
                }
                .disabled(refreshManager.refreshing)
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
