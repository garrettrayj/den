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
    let browserView: Bool

    var body: some View {
        suffixedTitle
            .font(.headline)
            .lineLimit(6)
            .imageScale(.small)
    }

    var suffixedTitle: Text {
        if browserView {
            return Text(title) +
            Text("\u{00A0}") +
            Text("\(Image(systemName: "link"))").font(.footnote).foregroundStyle(.secondary)
        }

        return Text(title)
    }
}
