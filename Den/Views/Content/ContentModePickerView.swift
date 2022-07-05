//
//  ContentModePickerView.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ContentModePickerView: View {
    @Binding var viewMode: Int

    var body: some View {
        Picker("View Mode", selection: $viewMode) {
            Label("Gadgets", systemImage: "rectangle.grid.3x2")
                .tag(ContentViewMode.gadgets.rawValue)
                .accessibilityIdentifier("gadgets-view-button")
            Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                .tag(ContentViewMode.showcase.rawValue)
                .accessibilityIdentifier("showcase-view-button")
            Label("Timeline", systemImage: "calendar.day.timeline.leading")
                .tag(ContentViewMode.timeline.rawValue)
                .accessibilityIdentifier("page-timeline-view-button")
            Label("Trends", systemImage: "chart.line.uptrend.xyaxis")
                .tag(ContentViewMode.trends.rawValue)
                .accessibilityIdentifier("page-trends-view-button")
        }
    }
}
