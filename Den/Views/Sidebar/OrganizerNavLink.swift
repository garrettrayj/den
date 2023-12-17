//
//  OrganizerNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 12/17/23.
//  Copyright © 2023 Garrett Johnson
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
        .accessibilityIdentifier("OrganizerNavLink")
    }
}
