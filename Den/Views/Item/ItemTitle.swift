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
    @ObservedObject var item: Item

    var body: some View {
        Text(item.wrappedTitle)
            .font(.headline)
            .lineLimit(6)
            .multilineTextAlignment(.leading)
    }
}
