//
//  PreviewDateline.swift
//  Den
//
//  Created by Garrett Johnson on 2/16/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct PreviewDateline: View {
    let date: Date

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.dateStyle = .medium
        formatter.locale = .current
        formatter.doesRelativeDateFormatting = true

        return formatter
    }()

    var body: some View {
        TimelineView(.everyMinute) { _ in
            Text(dateFormatter.string(from: date)).font(.subheadline.italic()).lineLimit(1)
        }
    }
}
