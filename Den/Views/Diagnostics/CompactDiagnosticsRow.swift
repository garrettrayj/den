//
//  CompactDiagnosticsRow.swift
//  Den
//
//  Created by Garrett Johnson on 7/10/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct CompactDiagnosticsRow: View {
    let data: DiagnosticsRowData
    
    var body: some View {
        VStack {
            Group {
                LabeledContent {
                    FeedTitleLabel(feed: data.entity)
                } label: {
                    Text("Feed", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.page)")
                } label: {
                    Text("Page", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.address)")
                } label: {
                    Text("Address", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    data.isSecure == 1 ? Text("Yes") : Text("No")
                } label: {
                    Text("Secure", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.format)")
                } label: {
                    Text("Format", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.responseTime) ms")
                } label: {
                    Text("Response Time", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text(verbatim: "\(data.httpStatus)")
                } label: {
                    Text("Status", comment: "Diagnostics header.")
                }
            }
            
            Group {
                LabeledContent {
                    if data.age != -1 {
                        Text("\(data.age) s")
                    }
                } label: {
                    Text("Age", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.cacheControl)")
                } label: {
                    Text("Cache Control", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.eTag)")
                } label: {
                    Text("ETag", comment: "Diagnostics header.")
                }
                
                LabeledContent {
                    Text("\(data.server)")
                } label: {
                    Text("Server", comment: "Diagnostics header.")
                }
            }
        }
    }
}
