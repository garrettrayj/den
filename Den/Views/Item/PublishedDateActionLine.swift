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
    let date: Date
    let browserView: Bool

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
                Text(verbatim: dateFormatter.string(from: date))
                if browserView == true {
                    Image(systemName: "link").imageScale(.small)
                }
            }
        }
    }
}
