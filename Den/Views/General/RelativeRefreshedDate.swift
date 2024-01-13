//
//  RelativeRefreshedDate.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct RelativeRefreshedDate: View {
    let date: Date

    static let relativeDateStyle: Date.RelativeFormatStyle = .relative(
        presentation: .numeric,
        unitsStyle: .wide
    )

    var body: some View {
        TimelineView(.everyMinute) { _ in
            if -date.timeIntervalSinceNow < 60 {
                Text(
                    "Updated Just Now",
                    comment: "Status message (refreshed less than one minute ago)."
                )
            } else {
                Text(
                    "Updated \(date.formatted(RelativeRefreshedDate.relativeDateStyle))",
                    comment: "Status message (relative date display)."
                )
            }
        }
    }
}
