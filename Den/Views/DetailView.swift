//
//  DetailView.swift
//  Den
//
//  Created by Garrett Johnson on 9/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct DetailColumn: View {
    @Binding var refreshing: Bool
    @Binding var searchInput: String
    @Binding var selection: Panel?
    @Binding var activeProfile: Profile?
    @ObservedObject var profile: Profile

    var body: some View {
        switch selection ?? .welcome {
        case .welcome:
            WelcomeView()
        case .search:
            SearchView(profile: profile, query: $searchInput)
        case .allItems:
            AllItemsView(profile: profile, refreshing: $refreshing)
        case .trends:
            TrendsView(profile: profile, refreshing: $refreshing)
        case .page(let id):
            if let page = profile.pagesArray.first(where: {$0.id == id}) {
                PageView(page: page, unreadCount: page.previewItems.unread().count, refreshing: $refreshing)
            }
        case .settings:
            SettingsView(activeProfile: $activeProfile)
        }
    }
}
