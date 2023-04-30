//
//  ItemTitle.swift
//  Den
//
//  Created by Garrett Johnson on 4/30/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemTitle: View {
    let item: Item

    var body: some View {
        titleText
            .imageScale(.small)
            .font(.headline)
            .lineLimit(6)
            .multilineTextAlignment(.leading)
    }

    private var titleText: some View {
        if item.feedData?.feed?.browserView == true {
            return Text("\(item.wrappedTitle) ") + Text("\(Image(systemName: "link"))").font(.callout)
        }

        return Text(item.wrappedTitle)
    }
}
