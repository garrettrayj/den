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
    @ObservedObject var profile: Profile

    @Binding var selection: Set<Feed>
    @Binding var showingInspector: Bool

    var body: some ToolbarContent {
        ToolbarItem {
            if selection.count == profile.feedsArray.count {
                Button {
                    selection.removeAll()
                } label: {
                    Label {
                        Text("Deselect All")
                    } icon: {
                        Image(systemName: "checklist.unchecked")
                    }
                }

            } else {
                Button {
                    selection = selection.union(profile.feedsArray)
                } label: {
                    Label {
                        Text("Select All")
                    } icon: {
                        Image(systemName: "checklist.checked")
                    }
                }
            }
        }

        ToolbarItem {
            InspectorToggleButton(showingInspector: $showingInspector)
        }
    }
}
