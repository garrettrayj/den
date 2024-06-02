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
                Text("Grouped", comment: "Layout option label.")
            } icon: {
                Image(systemName: "rectangle.grid.3x2")
            }
            .tag(PageLayout.grouped)
            .accessibilityIdentifier("GroupedLayout")

            Label {
                Text("Deck", comment: "Layout option label.")
            } icon: {
                Image(systemName: "rectangle.split.3x1")
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("DeckLayout")

            Label {
                Text("Timeline", comment: "Layout option label.")
            } icon: {
                Image(systemName: "calendar.day.timeline.leading")
            }
            .tag(PageLayout.timeline)
            .accessibilityIdentifier("TimelineLayout")
        } label: {
            Text("Layout", comment: "Picker label.")
        }
        .labelsHidden()
        .help(Text("Switch Layout", comment: "Button help text."))
        .accessibilityIdentifier("PageLayoutPicker")
    }
}
