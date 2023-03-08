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
    func body(content: Content) -> some View {
        content
            .background(.bar)
            .background(.background)
            .cornerRadius(8)
            .shadow(color: .black.opacity(0.2), radius: 4, x: 1, y: 1)
    }
}
