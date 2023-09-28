//
//  OrganizerNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerNavLink: View {
    var body: some View {
        NavigationLink(value: DetailPanel.organizer) {
            Label {
                Text("Organizer", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.gearshape")
            }
        }
        .accessibilityIdentifier("ShowOrganizer")
    }
}
