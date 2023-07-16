//
//  FeedSettingsButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedSettingsButton: View {
    @ObservedObject var feed: Feed

    @Binding var showingSettings: Bool

    var body: some View {
        Button {
            Task {
                showingSettings = true
                // Workaround for settings sheet not appearing on macOS
                feed.objectWillChange.send()
            }
        } label: {
            Label {
                Text("Feed Settings", comment: "Button label.")
            } icon: {
                Image(systemName: "wrench")
            }
        }
        .accessibilityIdentifier("ShowFeedSettings")
    }
}
