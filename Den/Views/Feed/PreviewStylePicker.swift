//
//  PreviewStylePicker.swift
//  Den
//
//  Created by Garrett Johnson on 4/27/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewStylePicker: View {
    @Binding var previewStyle: PreviewStyle

    var body: some View {
        Picker(selection: $previewStyle) {
            Label("Compressed", systemImage: "rectangle.compress.vertical").tag(PreviewStyle.compressed)
            Label("Expanded", systemImage: "rectangle.expand.vertical").tag(PreviewStyle.expanded)
        } label: {
            Text("Preferred Style").modifier(FormRowModifier())
        }
    }
}
