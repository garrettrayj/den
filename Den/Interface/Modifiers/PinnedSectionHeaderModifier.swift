//
//  PinnedSectionHeaderModifier.swift
//  Den
//
//  Created by Garrett Johnson on 11/21/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PinnedSectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(.thickMaterial)
            .background(
                Color(.systemGray3)
                    .colorInvert()
                    .opacity(0.1)
            )
    }
}
