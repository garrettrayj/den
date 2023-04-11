//
//  PreviewStyleButton.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewStyleButton: View {
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
                Label("Expand", systemImage: "rectangle.expand.vertical")
            } else {
                Label("Compress", systemImage: "rectangle.compress.vertical")
            }
        }
        .modifier(ToolbarButtonModifier())
        .accessibilityIdentifier("preview-style-button")
    }
}
