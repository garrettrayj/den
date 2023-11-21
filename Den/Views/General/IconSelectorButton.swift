//
//  IconSelectorButton.swift
//  Den
//
//  Created by Garrett Johnson on 9/17/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct IconSelectorButton: View {
    @Binding var showingIconSelector: Bool
    @Binding var symbol: String

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
    }
}
