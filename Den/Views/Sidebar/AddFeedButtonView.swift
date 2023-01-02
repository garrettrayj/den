//
//  AddFeedButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AddFeedButtonView: View {
    @Environment(\.editMode) private var editMode

    @Binding var contentSelection: ContentPanel?
    
    let profile: Profile

    var body: some View {
        if editMode?.wrappedValue == .inactive {
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
}
