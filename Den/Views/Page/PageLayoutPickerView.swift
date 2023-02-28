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
            Label("Gadgets", systemImage: "rectangle.grid.2x2")
                .tag(PageLayout.gadgets)
                .accessibilityIdentifier("gadgets-page-layout-option")

            Label("Showcase", systemImage: "square.grid.3x1.below.line.grid.1x2")
                .tag(PageLayout.showcase)
                .accessibilityIdentifier("showcase-page-layout-option")

            Label("Deck", systemImage: "rectangle.split.3x1")
                .tag(PageLayout.deck)
                .accessibilityIdentifier("deck-page-layout-option")

            Label("Blend", systemImage: "rectangle.grid.3x2")
                .tag(PageLayout.blend)
                .accessibilityIdentifier("blend-page-layout-option")
        }
        .accessibilityIdentifier("page-layout-picker")
    }
}
