//
//  NewFeedButton.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct NewFeedButton: View {
    var page: Page?

    var body: some View {
        Button {
            SubscriptionUtility.showSubscribe(page: page)
        } label: {
            Label {
                Text("New Feed", comment: "Button label.")
            } icon: {
                Image(systemName: "plus")
            }
        }
        
        .accessibilityIdentifier("new-feed-button")
    }
}
