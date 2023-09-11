//
//  OrganizerButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerButton: View {
    @Binding var detailPanel: DetailPanel?

    var body: some View {
        Button {
            detailPanel = .organizer
        } label: {
            Label {
                Text("Organizer")
            } icon: {
                Image(systemName: "wrench.and.screwdriver")
            }
        }
        .accessibilityIdentifier("ShowOrganizer")
    }
}
