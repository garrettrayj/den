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

    @AppStorage("HideRead") private var hideRead: Bool = false

    var body: some View {
        WithItems(scopeObject: profile) { items in
            InboxLayout(
                profile: profile,
                hideRead: $hideRead,
                items: items
            )
            .toolbar {
                InboxToolbar(profile: profile, hideRead: $hideRead, items: items)
            }
            .navigationTitle(Text("Inbox"))
        }
    }
}
