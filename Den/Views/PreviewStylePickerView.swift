//
//  PreviewStylePickerView.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewStylePickerView: View {
    @Binding var previewStyle: PreviewStyle

    var body: some View {
        Picker("Preview Style", selection: $previewStyle) {
            Label("Compact", systemImage: "square.text.square")
                .tag(PreviewStyle.compact)
                .accessibilityIdentifier("compact-preview-style-option")

            Label("Teaser", systemImage: "doc.richtext")
                .tag(PreviewStyle.teaser)
                .accessibilityIdentifier("teaser-preview-style-option")
        }
        .accessibilityIdentifier("preview-style-picker")
    }
}
