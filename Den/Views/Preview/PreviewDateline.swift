//
//  PreviewDateline.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

struct PreviewDateline: View {
    let date: Date

    static let dateFormatter: DateFormatter = {
        let relativeDateFormatter = DateFormatter()
        relativeDateFormatter.timeStyle = .short
        relativeDateFormatter.dateStyle = .medium
        relativeDateFormatter.locale = .current
        relativeDateFormatter.doesRelativeDateFormatting = true

        return relativeDateFormatter
    }()

    var body: some View {
        TimelineView(.everyMinute) { _ in
            Text(verbatim: PreviewDateline.dateFormatter.string(from: date))
                .font(.caption2)
                .lineLimit(1)
        }
    }
}
