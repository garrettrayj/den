//
//  PreviewStyleButtonView.swift
//  Den
//
//  Created by Garrett Johnson on 2/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewStyleButtonView: View {
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
                Label("Expand Items", systemImage: "rectangle.expand.vertical")
            } else {
                Label("Compress Items", systemImage: "rectangle.compress.vertical")
            }
        }
        .buttonStyle(ToolbarButtonStyle())
        .accessibilityIdentifier("preview-style-button")
    }
}
