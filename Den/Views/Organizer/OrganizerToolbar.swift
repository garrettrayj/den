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
    @Binding var showingInspectors: Bool

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
            Button {
                showingInspectors.toggle()
            } label: {
                Label {
                    Text("Toggle Inspectors")
                } icon: {
                    #if os(macOS)
                    Image(systemName: "sidebar.trailing")
                    #else
                    if UIDevice.current.userInterfaceIdiom == .phone {
                        Image(systemName: "rectangle.portrait.bottomhalf.inset.filled")
                    } else {
                        Image(systemName: "sidebar.trailing")
                    }
                    #endif
                }
            }
        }
    }
}
