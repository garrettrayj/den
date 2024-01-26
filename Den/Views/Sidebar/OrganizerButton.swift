//
//  OrganizerButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/23/23.
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
                Text("Organizer", comment: "Button label.")
            } icon: {
                Image(systemName: "folder.badge.gearshape")
            }
        }
        .accessibilityIdentifier("OrganizerButton")
    }
}
