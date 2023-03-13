//
//  ItemDateAuthorCompressedView.swift
//  Den
//
//  Created by Anonymous S.I. on 06/03/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import SwiftUI

struct ItemDateAuthorCompressedView: View {
    @Environment(\.isEnabled) private var isEnabled

    let item: Item

    var body: some View {
        Text("\(item.date.formatted()) • \(item.wrappedAuthor)")
            .lineLimit(1)
        .modifier(CustomFontModifier(relativeTo: .subheadline, textStyle: .subheadline))
        .lineLimit(1)
        .foregroundColor(
            isEnabled ?
                item.read ? Color(.tertiaryLabel) : Color(.secondaryLabel)
                :
                item.read ? Color(.quaternaryLabel) : Color(.tertiaryLabel)
        )
    }
}
