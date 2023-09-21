//
//  BasicHoverButtonStyle.swift
//  Den
//
//  Created by Garrett Johnson on 8/12/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct BasicHoverButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label.modifier(HoverHighlightModifier())
    }
}
