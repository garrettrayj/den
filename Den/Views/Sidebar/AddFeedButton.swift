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
    @Binding var contentSelection: ContentPanel?

    var body: some View {
        Button {
            if case .page(let page) = contentSelection {
                SubscriptionUtility.showSubscribe(page: page)
            } else {
                SubscriptionUtility.showSubscribe()
            }
        } label: {
            Label("Add Feed", systemImage: "plus.circle")
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("add-feed-button")
    }
}
