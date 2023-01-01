//
//  TrendsNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct TrendsNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Label {
                Text("Trends").lineLimit(1)
                    .badge(profile.trends.unread().count)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            .accessibilityIdentifier("timeline-button")
            .tag(RootPanel.trends)
        }
    }
}
