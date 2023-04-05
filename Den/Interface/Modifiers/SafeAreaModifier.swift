//
//  SafeAreaModifier.swift
//  Den
//
//  Created by Garrett Johnson on 4/4/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct SafeAreaModifier: ViewModifier {
    let geometry: GeometryProxy

    func body(content: Content) -> some View {
        content
            .onAppear {
                print(geometry.safeAreaInsets)
            }
            .safeAreaInset(edge: .leading, spacing: 0) {
                if geometry.safeAreaInsets.leading > 0 {
                    VStack {}.frame(width: geometry.safeAreaInsets.leading)
                }
            }
            .safeAreaInset(edge: .trailing, spacing: 0) {
                if geometry.safeAreaInsets.trailing > 0 {
                    VStack {}.frame(width: geometry.safeAreaInsets.trailing)
                }
            }
    }
}
