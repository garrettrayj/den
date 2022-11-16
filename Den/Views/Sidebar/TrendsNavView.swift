//
//  TrendsNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendsNavView: View {
    @ObservedObject var profile: Profile

    var body: some View {
        NavigationLink(value: Panel.trends) {
            Label {
                Text("Trends").lineLimit(1)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }
        .badge(profile.trends.unread().count)
        .accessibilityIdentifier("timeline-button")
    }
}
