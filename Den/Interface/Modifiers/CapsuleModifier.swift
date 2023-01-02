//
//  CapsuleModifier.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption.monospacedDigit())
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .overlay(Capsule().fill(Color(UIColor.secondarySystemFill)))
    }
}
