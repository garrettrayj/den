//
//  PreviewDateAndAction.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct PreviewDateAndAction: View {
    @Environment(\.isEnabled) private var isEnabled

    let date: Date?
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
        HStack(spacing: 4) {
            if let date = date {
                TimelineView(.everyMinute) { _ in
                    Text(verbatim: dateFormatter.string(from: date))
                }
            } else {
                Text("No Date", comment: "Date missing message.")
            }

            if browserView == true {
                Image(systemName: "link").imageScale(.small)
            }
        }
        .font(.caption2.weight(.semibold))
        .foregroundStyle(isEnabled ? .secondary : .tertiary)
    }
}
