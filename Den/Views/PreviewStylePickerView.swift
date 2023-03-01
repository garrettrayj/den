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
        Button {
            if previewStyle == .compressed {
                previewStyle = .expanded
            } else {
                previewStyle = .compressed
            }
        } label: {
            if previewStyle == .compressed {
                Label("Expand Previews", systemImage: "rectangle.expand.vertical")
            } else {
                Label("Compress Previews", systemImage: "rectangle.compress.vertical")
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("preview-style-button")
    }
}
