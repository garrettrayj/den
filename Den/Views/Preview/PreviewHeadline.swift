//
//  PreviewHeadline.swift
//  Den
//
//  Created by Garrett Johnson on 4/30/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewHeadline: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .lineLimit(6)
            .multilineTextAlignment(.leading)
    }
}
