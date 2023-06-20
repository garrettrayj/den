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
                Text("Gadgets", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "rectangle.grid.3x2")
            }
            .tag(PageLayout.gadgets)
            .accessibilityIdentifier("gadgets-layout-button")

            Label {
                Text("Blend", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "square.grid.3x3")
            }
            .tag(PageLayout.blend)
            .accessibilityIdentifier("blend-layout-button")

            Label {
                Text("Showcase", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "square.grid.3x1.below.line.grid.1x2")
            }
            .tag(PageLayout.showcase)
            .accessibilityIdentifier("showcase-layout-button")

            Label {
                Text("Deck", comment: "Page layout option label.")
            } icon: {
                Image(systemName: "rectangle.split.3x1")
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("deck-layout-button")
        } label: {
            Text("Page Layout", comment: "Picker label.")
        }
        .fontWeight(.medium)
        .accessibilityIdentifier("page-layout-picker")
    }
}
