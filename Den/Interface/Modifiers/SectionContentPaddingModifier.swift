//
//  SectionContentPaddingModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/20/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SectionContentPaddingModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}
