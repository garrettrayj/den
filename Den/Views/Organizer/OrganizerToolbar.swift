//
//  OrganizerToolbar.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftData
import SwiftUI

struct OrganizerToolbar: ToolbarContent {
    @Binding var selection: Set<Feed>
    
    let pages: [Page]

    var body: some ToolbarContent {
        ToolbarItem {
            Button {
                withAnimation {
                    if selection.count == pages.feeds.count {
                        selection.removeAll()
                    } else {
                        selection = selection.union(pages.feeds)
                    }
                }
            } label: {
                Label {
                    Text("Select", comment: "Button label.")
                } icon: {
                    if selection.count == pages.feeds.count {
                        Image(systemName: "checklist.unchecked")
                    } else {
                        Image(systemName: "checklist.checked")
                    }
                }
            }
            .contentTransition(.symbolEffect(.replace))
            .help(Text("Select all/none", comment: "Button help text."))
            .accessibilityIdentifier("SelectAllNone")
        }

        ToolbarItem {
            #if os(macOS)
            InspectorToggleButton(initialValue: true, storageKey: "ShowingOrganizerInspector")
            #else
            InspectorToggleButton(initialValue: false, storageKey: "ShowingOrganizerInspector")
            #endif
        }
    }
}
