//
//  DiagnosticsTable.swift
//  Den
//
//  Created by Garrett Johnson on 7/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct DiagnosticsTable: View {
    #if !os(macOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @ObservedObject var profile: Profile

    @State var sortOrder = [KeyPathComparator(\DiagnosticsRowData.responseTime, order: .reverse)]

    var data: [DiagnosticsRowData] {
        profile.feedsArray.map { $0.diagnosticsRowData }.sorted(using: sortOrder)
    }

    var body: some View {
        Table(data, sortOrder: $sortOrder) {
            Group {
                TableColumn(
                    "Feed",
                    value: \DiagnosticsRowData.title
                ) { row in
                    #if os(macOS)
                    FeedTitleLabel(feed: row.entity)
                    #else
                    if horizontalSizeClass == .compact {
                        CompactDiagnosticsRow(data: row)
                    } else {
                        FeedTitleLabel(feed: row.entity)
                    }
                    #endif
                }.width(min: 160)

                TableColumn(
                    "Page",
                    value: \DiagnosticsRowData.page
                ) { row in
                    row.entity.page?.nameText ?? Text("Not Available", comment: "Page name not available.")
                }

                TableColumn(
                    "Address",
                    value: \.address
                ) { row in
                    Text(verbatim: "\(row.address)")
                }

                TableColumn(
                    "Secure",
                    value: \.isSecure
                ) { row in
                    if row.isSecure == 1 {
                        Text("Yes", comment: "Boolean value.")
                    } else {
                        Text("No", comment: "Boolean value.")
                    }
                }.width(max: 60)

                TableColumn(
                    "Format",
                    value: \.format
                ).width(max: 60)

                TableColumn(
                    "Response Time",
                    value: \.responseTime
                ) { row in
                    Text("\(row.responseTime) ms", comment: "Time display (milliseconds).")
                }

                TableColumn(
                    "Status",
                    value: \DiagnosticsRowData.httpStatus
                ) { row in
                    if row.httpStatus != -1 {
                        Text(verbatim: "\(row.httpStatus)")
                    }
                }.width(max: 60)
            }

            Group {
                TableColumn(
                    "Age",
                    value: \DiagnosticsRowData.age
                ) { row in
                    if row.age != -1 {
                        Text("\(row.age) s", comment: "Time display (seconds).")
                    }
                }

                TableColumn(
                    "Cache Control",
                    value: \.cacheControl
                )

                TableColumn(
                    "ETag",
                    value: \.eTag
                )

                TableColumn(
                    "Server",
                    value: \.server
                )
            }
        }
        .textSelection(.enabled)
        .navigationTitle(Text("Diagnostics", comment: "Navigation title."))
    }
}
