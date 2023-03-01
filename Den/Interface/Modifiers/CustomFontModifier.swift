//
//  ContentFontModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/1/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CustomFontModifier: ViewModifier {
    @Environment(\.contentFontFamily) private var contentFontFamily
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let relativeTo: Font.TextStyle
    let textStyle: UIFont.TextStyle

    var fontSize: CGFloat {
        #if targetEnvironment(macCatalyst)
        return UIFont.preferredFont(forTextStyle: textStyle).pointSize * dynamicTypeSize.fontScale
        #else
        // Font will be pre-scaled on iOS. Make sure .dynamicTypeSize() call is on parent
        UIFont.preferredFont(forTextStyle: textStyle).pointSize
        #endif
    }

    func body(content: Content) -> some View {
        content.font(.custom(
            contentFontFamily,
            size: fontSize,
            relativeTo: relativeTo
        ))
    }
}
