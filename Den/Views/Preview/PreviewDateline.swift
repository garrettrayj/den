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
    let date: Date

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.doesRelativeDateFormatting = true

        return formatter
    }()
    
    static let helpDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .full
        formatter.locale = .current
        formatter.doesRelativeDateFormatting = false

        return formatter
    }()

    var body: some View {
        TimelineView(.everyMinute) { _ in
            Text(verbatim: PreviewDateline.dateFormatter.string(from: date))
                .font(.caption2)
                .lineLimit(1)
                .help(Text(
                    verbatim: """
                    \(date.formatted(date: .complete, time: .shortened)) \
                    (\(date.formatted(.relative(presentation: .numeric))))
                    """
                ))
        }
    }
}
