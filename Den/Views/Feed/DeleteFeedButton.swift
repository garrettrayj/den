//
//  DeleteFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/18/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DeleteFeedButton: View {
    @Environment(\.modelContext) private var modelContext

    @Bindable var feed: Feed

    var body: some View {
        Button(role: .destructive) {
            if let feedData = feed.feedData { modelContext.delete(feedData) }
            modelContext.delete(feed)
        } label: {
            DeleteLabel()
        }
        .accessibilityIdentifier("DeleteFeed")
    }
}
