//
//  SectionBoardModifier.swift
//  Den
//
//  Created by Garrett Johnson on 2/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SectionBoardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal)
            .padding(.vertical, 8)
    }
}
