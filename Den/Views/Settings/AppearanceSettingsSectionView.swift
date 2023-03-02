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
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    @Binding var uiStyle: UIUserInterfaceStyle
    @Binding var contentSizeCategory: UIContentSizeCategory
    @Binding var contentFontFamily: String

    var body: some View {
        Section(header: Text("Appearance")) {
            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Theme").modifier(FormRowModifier())
                Spacer()
                UIStylePickerView(uiStyle: $uiStyle)
                .labelsHidden()
                .frame(maxWidth: 112)
            }
            #else
            UIStylePickerView(uiStyle: $uiStyle)
            #endif

            #if targetEnvironment(macCatalyst)
            HStack {
                Text("Content Size").modifier(FormRowModifier())
                Spacer()
                ContentSizePickerView(contentSizeCategory: $contentSizeCategory)
                    .labelsHidden()
                    .frame(maxWidth: 172)
            }
            #else
            ContentSizePickerView(contentSizeCategory: $contentSizeCategory)
            #endif

            FontPickerView(fontFamily: $contentFontFamily)
                .dynamicTypeSize(DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize)
        }
    }
}
