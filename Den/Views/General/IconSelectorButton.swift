//
//  IconSelectorButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct IconSelectorButton: View {
    @Binding var symbol: String

    @State private var showingIconSelector = false

    var body: some View {
        Button {
            showingIconSelector = true
        } label: {
            Label {
                HStack {
                    Text("Choose Icon", comment: "Button label.")
                    Spacer()
                    ButtonChevron()
                }
            } icon: {
                Image(systemName: symbol)
            }
        }
        .buttonStyle(.borderless)
        .navigationDestination(isPresented: $showingIconSelector) {
            IconSelector(symbol: $symbol)
        }
    }
}
