//
//  ThumbnailModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/26/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ThumbnailModifier: ViewModifier {
    let width: CGFloat
    let height: CGFloat

    func body(content: Content) -> some View {
        content
            .frame(width: width, height: height)
            .background(.tertiary)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8).stroke(.tertiary, lineWidth: 1)
            )
            .accessibility(label: Text("Thumbnail", comment: "Accessibility label."))
    }
}
