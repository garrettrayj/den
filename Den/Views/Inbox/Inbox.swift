//
//  Inbox.swift
//  Den
//
//  Created by Garrett Johnson on 7/4/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct Inbox: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var refreshing: Bool

    var body: some View {
        InboxLayout(profile: profile, hideRead: hideRead)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    AddFeedButton()
                }
                ToolbarItemGroup(placement: .bottomBar) {
                    InboxBottomBar(profile: profile, refreshing: $refreshing, hideRead: $hideRead)
                }
            }
            .navigationTitle("Inbox")
    }
}
