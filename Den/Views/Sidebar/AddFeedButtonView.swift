//
//  AddFeedButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 12/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct AddFeedButtonView: View {
    @Environment(\.editMode) private var editMode

    @Binding var selection: Panel?

    var body: some View {
        if editMode?.wrappedValue == .inactive {
            Button {
                if case .page(let page) = selection {
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
