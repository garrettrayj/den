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
    @Environment(\.horizontalSizeClass) var sizeCategory
    
    @ObservedObject var profile: Profile
    
    @State var sortOrder = [KeyPathComparator(\DiagnosticsRowData.responseTime, order: .reverse)]
    
    var data: [DiagnosticsRowData] {
        profile.feedsArray.map { $0.diagnosticsRowData }.sorted(using: sortOrder)
    }
    
    var body: some View {
        Table(data, sortOrder: $sortOrder) {
            Group {
                TableColumn(
                    Text("Feed", comment: "Diagnostics header."),
                    value: \DiagnosticsRowData.title
                ) { row in
                    if (sizeCategory == .compact) {
                        CompactDiagnosticsRow(data: row)
                    } else {
                        FeedTitleLabel(feed: row.entity)
                    }
                }.width(min: 160)
                
                TableColumn(
                    Text("Page", comment: "Diagnostics header."),
                    value: \.page
                ).width(min: 100)
                
                TableColumn(
                    Text("Address", comment: "Diagnostics header."),
                    value: \.address
                ) { row in
                    Text(row.address)
                }
                
                TableColumn(
                    Text("Is Secure", comment: "Diagnostics header."),
                    value: \.isSecure
                ) { row in
                    if row.isSecure == 1 {
                        Text("Yes", comment: "Boolean value.")
                    } else {
                        Text("No", comment: "Boolean value.")
                    }
                }
                
                TableColumn(
                    Text("Format", comment: "Diagnostics header."),
                    value: \.format
                )
                
                TableColumn(
                    Text("Response Time", comment: "Diagnostics header."),
                    value: \.responseTime
                ) { row in
                    Text("\(row.responseTime) ms", comment: "Time display (milliseconds).")
                }
                
                TableColumn(
                    Text("Status Code", comment: "Diagnostics header."),
                    value: \DiagnosticsRowData.httpStatus
                ) { row in
                    if row.httpStatus != -1 {
                        Text(verbatim: "\(row.httpStatus)")
                    }
                }
            }
            
            Group {
                TableColumn(
                    Text("Age", comment: "Diagnostics header."),
                    value: \DiagnosticsRowData.age
                ) { row in
                    if row.age != -1 {
                        Text("\(row.age) s", comment: "Time display (seconds).")
                    }
                }
                
                TableColumn(
                    Text("Cache Control", comment: "Diagnostics header."),
                    value: \.cacheControl
                )
                
                TableColumn(
                    Text("ETag", comment: "Diagnostics header."),
                    value: \.eTag
                )
                
                TableColumn(
                    Text("Server", comment: "Diagnostics header."),
                    value: \.server
                )
            }
        }
        .textSelection(.enabled)
        .navigationTitle(Text("Diagnostics", comment: "Navigation title."))
    }
}
