//
//  AddFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AddFeedButton: View {
    var page: Page?

    var body: some View {
        Button {
            if page != nil {
                SubscriptionUtility.showSubscribe(page: page)
            } else {
                SubscriptionUtility.showSubscribe()
            }
        } label: {
            Label {
                Text("Add Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "plus.circle")
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("add-feed-button")
    }
}
