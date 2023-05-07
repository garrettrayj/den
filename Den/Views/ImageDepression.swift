//
//  ImageDepression.swift
//  Den
//
//  Created by Garrett Johnson on 3/21/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ImageDepression<Content: View>: View {
    var padding: CGFloat = 8
    var cornerRadius: CGFloat = 6

    @ViewBuilder
    var content: () -> Content

    var body: some View {
        VStack(spacing: 0) {
            content()
        }
        .frame(maxWidth: .infinity)
        .padding(padding)
        .background(.quaternary)
        .cornerRadius(cornerRadius)
    }
}
