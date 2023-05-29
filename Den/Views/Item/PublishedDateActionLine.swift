//
//  PublishedDateActionLine.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PublishedDateActionLine: View {
    @ObservedObject var item: Item
    @ObservedObject var feed: Feed

    let dateFormatter: DateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = .current
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    var body: some View {
        TimelineView(.everyMinute) { _ in
            HStack {
                Text(verbatim: dateFormatter.string(from: item.date))
                if feed.browserView == true {
                    Image(systemName: "link").imageScale(.small)
                }
            }
        }
    }
}
