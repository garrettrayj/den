//
//  GoToFeedNavLink.swift
//  Den
//
//  Created by Garrett Johnson on 7/26/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct GoToFeedNavLink: View {
    var feedObjectURL: URL
    
    var body: some View {
        NavigationLink(value: SubDetailPanel.feed(feedObjectURL)) {
            Label {
                Text("Go to Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "dot.radiowaves.up.forward")
            }
        }
    }
}
