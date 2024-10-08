//
//  ImageBorderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/21/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ImageBorderModifier: ViewModifier {
    var cornerRadius: CGFloat = 8

    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(.separator.quinary, lineWidth: 1)
            )
    }
}
