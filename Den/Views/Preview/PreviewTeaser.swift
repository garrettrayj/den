//
//  PreviewTeaser.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewTeaser: View {
    let teaser: String

    var body: some View {
        Text(teaser)
            .font(.subheadline)
            .lineLimit(6)
            .padding(.top, 4)
            .lineSpacing(2)
    }
}
