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
            .accessibilityIdentifier("GroupedLayout")

            Label {
                Text("Timeline", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "calendar.day.timeline.left")
            }
            .tag(PageLayout.timeline)
            .accessibilityIdentifier("TimelineLayout")

            Label {
                Text("Showcase", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "square.grid.3x1.below.line.grid.1x2")
            }
            .tag(PageLayout.showcase)
            .accessibilityIdentifier("ShowcaseLayout")

            Label {
                Text("Deck", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "rectangle.split.3x1")
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("DeckLayout")
        } label: {
            Text("Layout", comment: "Picker label.")
        }
        .fontWeight(.medium)
        .accessibilityIdentifier("PageLayoutPicker")
    }
}
