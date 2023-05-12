//
//  TrendingNav.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingNav: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    var body: some View {
        NavigationLink(value: DetailPanel.trending) {
            Label {
                Text("Trending").lineLimit(1).badge(profile.trends.containingUnread().count)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }
        #if !targetEnvironment(macCatalyst)
        .modifier(ListRowModifier())
        #endif
        .accessibilityIdentifier("trends-button")
    }
}
