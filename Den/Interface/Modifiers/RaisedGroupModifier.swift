//
//  RaisedGroupModifier.swift
//  Den
//
//  Created by Garrett Johnson on 3/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct RaisedGroupModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    
    func body(content: Content) -> some View {
        content
            .background(.bar)
            .background(.background)
            .cornerRadius(8)
            .shadow(
                color: .black.opacity(colorScheme == .light ? 0.15 : 0.5),
                radius: 4,
                x: 1,
                y: 1
            )
    }
}
