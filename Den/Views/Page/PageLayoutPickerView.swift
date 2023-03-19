//
//  PageLayoutPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 2/28/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PageLayoutPickerView: View {
    @Binding var pageLayout: PageLayout

    var body: some View {
        Picker("Page Layout", selection: $pageLayout) {
            Label {
                Text("Gadgets")
            } icon: {
                Image(systemName: "rectangle.grid.3x2")
            }
            .tag(PageLayout.gadgets)
            .accessibilityIdentifier("gadgets-page-layout-option")

            Label {
                Text("Blend")
            } icon: {
                Image(systemName: "square.grid.3x3")
            }
            .tag(PageLayout.blend)
            .accessibilityIdentifier("blend-page-layout-option")

            Label {
                Text("Showcase")
            } icon: {
                Image(systemName: "square.grid.3x1.below.line.grid.1x2")
            }
            .tag(PageLayout.showcase)
            .accessibilityIdentifier("showcase-page-layout-option")

            Label {
                Text("Deck")
            } icon: {
                Image(systemName: "rectangle.split.3x1")
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("deck-page-layout-option")

        }
        .accessibilityIdentifier("page-layout-picker")
    }
}
