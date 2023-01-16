//
//  TrendsNavView.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendsNavView: View {
    @Environment(\.editMode) private var editMode

    @ObservedObject var profile: Profile

    var body: some View {
        Label {
            Text("Trends").lineLimit(1)
                .badge(editMode?.wrappedValue.isEditing == true ? 0 : profile.trends.unread().count)
        } icon: {
            Image(systemName: "chart.line.uptrend.xyaxis")
        }
        .accessibilityIdentifier("timeline-button")
        .tag(ContentPanel.trends)
        .foregroundColor(editMode?.wrappedValue == .active ? .secondary : nil)
    }
}
