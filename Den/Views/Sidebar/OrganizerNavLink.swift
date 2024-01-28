//
//  OrganizerNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 1/22/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct OrganizerNavLink: View {
    var body: some View {
        Label {
            Text("Organizer", comment: "Button label.")
        } icon: {
            Image(systemName: "folder.badge.gearshape")
        }
        .tag(DetailPanel.organizer)
        .accessibilityIdentifier("OrganizerButton")
    }
}
