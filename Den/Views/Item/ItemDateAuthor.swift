//
//  ItemDateAuthor.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ItemDateAuthor: View {
    let item: Item

    var dateStyle: Date.FormatStyle.DateStyle = .abbreviated
    var timeStyle: Date.FormatStyle.TimeStyle = .shortened

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 4) {
                linkDateLine
                if let author = item.author {
                    Text("•")
                    Text(author)
                }
            }

            VStack(alignment: .leading) {
                linkDateLine
                if let author = item.author {
                    Text(author)
                }
            }
        }
        .font(.subheadline)
        .lineLimit(1)
        .imageScale(.small)
    }

    private var linkDateLine: some View {
        if item.feedData?.feed?.browserView == true {
            return Text("\(formattedDateString) \(Image(systemName: "link"))")
        }

        return Text(formattedDateString)
    }

    private var formattedDateString: String {
        item.date.formatted(date: dateStyle, time: timeStyle)
    }
}
