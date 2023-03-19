//
//  ContentSizePickerView.swift
//  Den
//
//  Created by Garrett Johnson on 3/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ContentSizePickerView: View {
    @Binding var contentSizeCategory: UIContentSizeCategory

    var body: some View {
        Picker(selection: $contentSizeCategory) {
            Text("Default").tag(UIContentSizeCategory.unspecified)
            Group {
                Text("Micro").tag(UIContentSizeCategory.extraSmall)
                Text("Small").tag(UIContentSizeCategory.small)
                Text("Medium").tag(UIContentSizeCategory.medium)
                Text("Large").tag(UIContentSizeCategory.large)
                Text("XL").tag(UIContentSizeCategory.extraLarge)
                Text("XXL").tag(UIContentSizeCategory.extraExtraLarge)
                Text("XXXL").tag(UIContentSizeCategory.extraExtraExtraLarge)
            }
            Group {
                Text("Accessibility Medium").tag(UIContentSizeCategory.accessibilityMedium)
                Text("Accessibility Large").tag(UIContentSizeCategory.accessibilityLarge)
                Text("Accessibility XL").tag(UIContentSizeCategory.accessibilityExtraLarge)
                Text("Accessibility XXL").tag(UIContentSizeCategory.accessibilityExtraExtraLarge)
                Text("Accessibility XXXL").tag(UIContentSizeCategory.accessibilityExtraExtraExtraLarge)
            }
        } label: {
            Text("Content Size").modifier(FormRowModifier())
        }
        .accessibilityIdentifier("content-size-picker")
    }
}
