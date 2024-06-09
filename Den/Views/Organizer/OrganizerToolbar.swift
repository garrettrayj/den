//
//  OrganizerToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerToolbar: ToolbarContent {
    @Binding var selection: Set<Feed>
    @Binding var showingInspector: Bool
    
    let pages: [Page]

    var body: some ToolbarContent {
        ToolbarItem {
            if selection.count == pages.feeds.count {
                Button {
                    selection.removeAll()
                } label: {
                    Label {
                        Text("Select None", comment: "Button label.")
                    } icon: {
                        Image(systemName: "checklist.unchecked")
                    }
                }
                .help(Text("Select None", comment: "Button help text."))
                .accessibilityIdentifier("Select None")
            } else {
                Button {
                    selection = selection.union(pages.feeds)
                } label: {
                    Label {
                        Text("Select All", comment: "Button label.")
                    } icon: {
                        Image(systemName: "checklist.checked")
                    }
                }
                .help(Text("Select All", comment: "Button help text."))
                .accessibilityIdentifier("SelectAll")
            }
        }

        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
    }
}
