//
//  OrganizerNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct OrganizerNavLink: View {
    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            detailPanel = .organizer
        } label: {
            Label {
                Text("Organizer", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.gearshape")
            }
        }
        .accessibilityIdentifier("ShowOrganizer")
    }
}
