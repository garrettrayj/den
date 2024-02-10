//
//  PreviewTeaser.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

struct PreviewTeaser: View {
    let teaser: String

    var body: some View {
        Text(teaser)
            .font(.subheadline)
            .lineSpacing(2)
            .lineLimit(6)
    }
}
