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
    @Binding var searchQuery: String
    
    @State private var path = NavigationPath()

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                switch detailPanel ?? .welcome {
                case .welcome:
                    Welcome(profile: profile)
                case .search:
                    Search(profile: profile, hideRead: $hideRead, query: $searchQuery)
                case .inbox:
                    Inbox(profile: profile, hideRead: $hideRead)
                case .trending:
                    Trending(profile: profile, hideRead: $hideRead)
                case .page(let page):
                    PageView(
                        page: page,
                        profile: profile,
                        hideRead: $hideRead
                    )
                }
            }
            .disabled(refreshManager.refreshing)
            .navigationDestination(for: SubDetailPanel.self) { panel in
                switch panel {
                case .feed(let feed):
                    FeedView(
                        feed: feed,
                        profile: profile,
                        hideRead: $hideRead
                    )
                case .item(let item):
                    ItemView(item: item)
                case .trend(let trend):
                    TrendView(trend: trend, profile: profile, hideRead: $hideRead)
                }
            }
        }
        .onChange(of: detailPanel) { _ in
            path.removeLast(path.count)
        }
    }
}
