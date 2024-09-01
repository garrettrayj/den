//
//  RelativeRefreshedDate.swift
//  Den
//
//  Created by Garrett Johnson on 5/29/23.
//  Copyright © 2023 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct RelativeRefreshedDate: View {
    let timestamp: Double
    
    var date: Date {
        return Date(timeIntervalSince1970: timestamp)
    }

    static let formatStyle: Date.RelativeFormatStyle = .relative(
        presentation: .numeric,
        unitsStyle: .wide
    )

    var body: some View {
        TimelineView(.everyMinute) { _ in
            Group {
                if -date.timeIntervalSinceNow < 60 {
                    Text(
                        "Updated Just Now",
                        comment: "Status message (refreshed less than one minute ago)."
                    )
                } else {
                    Text(
                        "Updated \(date.formatted(RelativeRefreshedDate.formatStyle))",
                        comment: "Status message (relative date display)."
                    )
                }
            }
            .help(Text(date.formatted(date: .complete, time: .shortened)))
        }
    }
}
