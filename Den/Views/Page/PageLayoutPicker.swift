//
//  PageLayoutPicker.swift
//  Den
//
//  Created by Garrett Johnson on 2/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageLayoutPicker: View {
    @Binding var pageLayout: PageLayout

    var body: some View {
        Picker(selection: $pageLayout) {
            Label {
                Text("Grouped", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "rectangle.grid.2x2")
            }
            .tag(PageLayout.grouped)
            .accessibilityIdentifier("grouped-layout-option")

            Label {
                Text("Timeline", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "calendar.day.timeline.left")
            }
            .tag(PageLayout.timeline)
            .accessibilityIdentifier("timeline-layout-option")

            Label {
                Text("Showcase", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "square.grid.3x1.below.line.grid.1x2")
            }
            .tag(PageLayout.showcase)
            .accessibilityIdentifier("showcase-layout-option")

            Label {
                Text("Deck", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "rectangle.split.3x1")
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("deck-layout-option")
        } label: {
            Text("Page Layout", comment: "Picker label.")
        }
        .fontWeight(.medium)
        .accessibilityIdentifier("page-layout-picker")
    }
}
