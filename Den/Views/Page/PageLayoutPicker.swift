//
//  PageLayoutPicker.swift
//  Den
//
//  Created by Garrett Johnson on 2/28/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct PageLayoutPicker: View {
    @Binding var pageLayout: PageLayout
    
    let pageWidth: CGFloat

    var body: some View {
        Picker(selection: $pageLayout) {
            Label {
                Text("Grouped", comment: "Page layout option label.")
            } icon: {
                Image(systemName: groupedIcon)
            }
            .tag(PageLayout.grouped)
            .accessibilityIdentifier("GroupedLayout")

            Label {
                Text("Deck", comment: "Page layout option label.")
            } icon: {
                Image(systemName: deckIcon)
            }
            .tag(PageLayout.deck)
            .accessibilityIdentifier("DeckLayout")

            Label {
                Text("Timeline", comment: "Page layout option label.")
            } icon: {
                Image(systemName: timelineIcon)
            }
            .tag(PageLayout.timeline)
            .accessibilityIdentifier("TimelineLayout")
        } label: {
            Text("Layout", comment: "Picker label.")
        }
        .fontWeight(.medium)
        .accessibilityIdentifier("PageLayoutPicker")
    }
    
    private var groupedIcon: String {
        if pageWidth < 570 {
            return "rectangle.grid.1x2"
        } else if pageWidth < 920 {
            return "rectangle.grid.2x2"
        } else {
            return "rectangle.grid.3x2"
        }
    }
    
    private var deckIcon: String {
        if pageWidth < 570 {
            return "rectangle.portrait.arrowtriangle.2.outward"
        } else if pageWidth < 920 {
            return "rectangle.split.2x1"
        } else {
            return "rectangle.split.3x1"
        }
    }
    
    private var timelineIcon: String {
        return "calendar.day.timeline.leading"
    }
}
