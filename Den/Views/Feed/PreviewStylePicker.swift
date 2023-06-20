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
            Label {
                Text("Compressed", comment: "Preview style picker option.")
            } icon: {
                Image(systemName: "rectangle.compress.vertical")
            }.tag(PreviewStyle.compressed)
            Label {
                Text("Expanded", comment: "Preview style picker option.")
            } icon: {
                Image(systemName: "rectangle.expand.vertical")
            }.tag(PreviewStyle.expanded)
        } label: {
            Text("Preferred Style", comment: "Preview style picker label.")
        }
    }
}
