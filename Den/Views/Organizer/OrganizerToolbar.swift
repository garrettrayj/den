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
    
    let pages: FetchedResults<Page>

    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                if selection.count == pages.feeds.count {
                    selection.removeAll()
                } else {
                    selection = selection.union(pages.feeds)
                }
            } label: {
                Label {
                    if selection.count == pages.feeds.count {
                        Text("Deselect All", comment: "Button label.")
                    } else {
                        Text("Select All", comment: "Button label.")
                    }
                } icon: {
                    if selection.count == pages.feeds.count {
                        Image(systemName: "checklist.unchecked")
                    } else {
                        Image(systemName: "checklist.checked")
                    }
                }
            }
            .help(Text("Select all/none", comment: "Button help text."))
            .accessibilityIdentifier("SelectAllNone")
        }

        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
    }
}
