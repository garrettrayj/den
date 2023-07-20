//
//  ConfigureFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 6/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ConfigureFeedButton: View {
    @ObservedObject var feed: Feed

    @Binding var showingFeedConfiguration: Bool

    var body: some View {
        Button {
            Task {
                showingFeedConfiguration = true
            }
        } label: {
            Label {
                Text("Configure", comment: "Button label.")
            } icon: {
                Image(systemName: "hammer")
            }
        }
        .accessibilityIdentifier("ConfigureFeed")
    }
}
