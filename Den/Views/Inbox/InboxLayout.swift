//
//  InboxLayout.swift
//  Den
//
//  Created by Garrett Johnson on 3/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct InboxLayout: View {
    @ObservedObject var profile: Profile

    @Binding var hideRead: Bool
    @Binding var showingNewFeedSheet: Bool

    let items: FetchedResults<Item>

    var body: some View {
        EmptyView()
    }
}
