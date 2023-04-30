//
//  ItemCompressed.swift
//  Den
//
//  Created by Garrett Johnson on 6/29/20.
//  Copyright © 2020 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemCompressed: View {
    @ObservedObject var item: Item

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                ItemTitle(item: item)
                ItemDateAuthor(item: item)
            }
            if item.feedData?.feed?.hideImages != true {
                Spacer()
                ItemThumbnailImage(item: item)
            }
        }
        .padding(12)
        .fixedSize(horizontal: false, vertical: true)
    }
}
