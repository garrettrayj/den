//
//  PreviewAuthor.swift
//  Den
//
//  Created by Garrett Johnson on 9/13/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewAuthor: View {
    @Environment(\.isEnabled) private var isEnabled

    let author: String

    var body: some View {
        Text(author)
            .font(.subheadline.weight(.medium))
            .lineLimit(2)
            .foregroundStyle(isEnabled ? .secondary : .tertiary)
    }
}
