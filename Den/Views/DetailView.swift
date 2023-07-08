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
    
    @State private var path = NavigationPath()
    
    var body: some View {
        NavigationStack {
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
            .disabled(refreshManager.refreshing)
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
        }
        .onChange(of: detailPanel) { _ in
            path.removeLast(path.count)
        }
    }
}
