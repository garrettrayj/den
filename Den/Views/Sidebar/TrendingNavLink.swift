//
//  TrendingNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingNavLink: View {
    var body: some View {
        Label {
            Text("Trending", comment: "Button label.").lineLimit(1)
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
        }
        .tag(DetailPanel.trending)
        .accessibilityIdentifier("TrendingNavLink")
    }
}
