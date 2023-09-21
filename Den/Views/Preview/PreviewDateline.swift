//
//  PreviewDateline.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewDateline: View {
    let date: Date?

    let dateFormatter: DateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = .current
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    var body: some View {
        Group {
            if let date = date {
                TimelineView(.everyMinute) { _ in
                    Text(verbatim: dateFormatter.string(from: date))
                }
            } else {
                Text("No Date", comment: "Date missing message.")
            }
        }
        .font(.caption2)
    }
}
