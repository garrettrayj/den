//
//  AppearanceSettingsSectionView.swift
//  Den
//
//  Created by Garrett Johnson on 8/11/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct AppearanceSettingsSectionView: View {
    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var contentSizeCategory: UIContentSizeCategory

    var body: some View {
        Section(header: Text("Appearance")) {
            Picker(selection: $uiStyle) {
                Text("Automatic").tag(UIUserInterfaceStyle.unspecified)
                Text("Light").tag(UIUserInterfaceStyle.light)
                Text("Dark").tag(UIUserInterfaceStyle.dark)
            } label: {
                Text("Theme")
            }.modifier(FormRowModifier())

            #if !targetEnvironment(macCatalyst)
            Picker(selection: $contentSizeCategory) {
                Text("Automatic").tag(UIContentSizeCategory.unspecified)
                Group {
                    Text("Extra Small").tag(UIContentSizeCategory.extraSmall)
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
                Text("Text Size")
            }
            #endif
        }
    }
}
