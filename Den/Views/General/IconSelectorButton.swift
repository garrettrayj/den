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
                Text("Select Icon", comment: "Button label.")
            } icon: {
                Image(systemName: symbol)
            }
        }
        .buttonStyle(.borderless)
        .sheet(isPresented: $showingIconSelector) {
            IconSelector(symbol: $symbol)
        }
    }
}
