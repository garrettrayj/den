//
//  FontPickerView.swift
//  Den
//
//  Created by Garrett Johnson on 3/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FontPickerView: View {
    @Environment(\.contentSizeCategory) private var contentSizeCategory
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var fontFamily: String

    var fontSize: CGFloat {
        let typeSize = DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize
        return UIFont.preferredFont(forTextStyle: .body).pointSize * typeSize.fontScale
    }

    var systemFont: String {
        UIFont.systemFont(ofSize: 12).familyName
    }

    var body: some View {
        Picker(selection: $fontFamily) {
            Text("System UI")
                .font(.custom(systemFont, fixedSize: fontSize))
                .padding(.vertical, 8)
                .tag(systemFont)

            ForEach(UIFont.familyNames.sorted(), id: \.self) { font in
                Text(font)
                    .font(.custom(font, fixedSize: fontSize))
                    .padding(.vertical, 8)
                    .tag(font)
            }
        } label: {
            Text("Font Family").modifier(FormRowModifier())
        }
        .pickerStyle(.navigationLink)
        .accessibilityIdentifier("font-picker")

    }
}
