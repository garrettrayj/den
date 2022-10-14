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
        NavigationLink(value: Panel.trends) {
            Label {
                HStack {
                    Text("Trends").modifier(SidebarItemLabelTextModifier())
                    Spacer()
                    Text(String(profile.trends.unread().count)).modifier(CapsuleModifier())
                }.lineLimit(1)
            } icon: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
        }
        .accessibilityIdentifier("timeline-button")
    }
}
