//
//  PageSelectionView.swift
//  Den
//
//  Created by Garrett Johnson on 9/3/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PageSelectionView: View {

    let allSelected: Bool
    let noneSelected: Bool
    let selectAll: () -> Void
    let selectNone: () -> Void

    var body: some View {
        HStack(alignment: .bottom) {
            Text("Select")
            Spacer()
            HStack {
                Button(action: selectAll) { Text("All") }
                    .disabled(allSelected)
                    .accessibilityIdentifier("import-select-all-button")
                Text("/").foregroundColor(.secondary)
                Button(action: selectNone) { Text("None") }
                    .disabled(noneSelected)
                    .accessibilityIdentifier("import-select-none-button")
            }
            .font(.system(size: 12))
        }
        .buttonStyle(.borderless)
        .modifier(FormFirstHeaderModifier())
    }
}
