//
//  ArticleDate.swift
//  Den
//
//  Created by Garrett Johnson on 9/14/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct ArticleDate: View {
    let date: Date
    
    var body: some View {
        TimelineView(.everyMinute) { _ in
            HStack(spacing: 4) {
                Text(verbatim: date.formatted(date: .complete, time: .shortened))
                Text(verbatim: "(\(date.formatted(.relative(presentation: .numeric))))")
            }
            .font(.caption2)
        }
    }
}
