//
//  BulkSelectionButtons.swift
//  Den
//
//  Created by Garrett Johnson on 9/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BulkSelectionButtons: View {
    let allSelected: Bool
    let noneSelected: Bool
    let selectAll: () -> Void
    let selectNone: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            Text("Select", comment: "Bulk select controls label")
            Spacer()
            HStack {
                Button(action: selectAll) { Text("All", comment: "Bulk select button label") }
                    .disabled(allSelected)
                    .accessibilityIdentifier("select-all-button")
                Text(verbatim: "/").foregroundColor(.secondary)
                Button(action: selectNone) { Text("None", comment: "Bulk select button label") }
                    .disabled(noneSelected)
                    .accessibilityIdentifier("select-none-button")
            }
            .font(.caption)
            .buttonStyle(.borderless)
        }
    }
}
