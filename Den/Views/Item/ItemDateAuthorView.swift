//
//  ItemDateAuthorView.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import Foundation

import SwiftUI

struct ItemDateAuthorView: View {
    @Environment(\.isEnabled) private var isEnabled

    let item: Item

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 4) {
                Text("\(item.date.formatted())")
                if let author = item.author {
                    Text("•")
                    Text(author)
                }
            }

            VStack(alignment: .leading) {
                Text("\(item.date.formatted())")
                if let author = item.author {
                    Text(author)
                }
            }
        }
        .font(.subheadline)
        .lineLimit(1)
        .foregroundColor(
            isEnabled ?
                item.read ? Color(UIColor.tertiaryLabel) : .secondary
                :
                item.read ? Color(UIColor.quaternaryLabel) : Color(UIColor.tertiaryLabel)
        )
    }
}
