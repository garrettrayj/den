//
//  CapsuleModifier.swift
//  Den
//
//  Created by Garrett Johnson on 7/30/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct CapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption.weight(.medium))
            .foregroundColor(Color(UIColor.secondaryLabel))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .overlay(
                Capsule().fill(Color(UIColor.secondarySystemFill))
            )
    }
}
