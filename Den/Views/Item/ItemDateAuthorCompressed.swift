//
//  ItemDateAuthorCompressed.swift
//  Den
//
//  Created by Anonymous S.I. on 06/03/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import SwiftUI

struct ItemDateAuthorCompressed: View {
    let item: Item

    var body: some View {
        Text("\(item.date.formatted()) • \(item.wrappedAuthor)")
            .lineLimit(1)
            .font(.subheadline)
        .lineLimit(1)
    }
}
