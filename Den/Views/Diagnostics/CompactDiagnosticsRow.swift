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
                    Text("Feed")
                }
                
                LabeledContent {
                    Text(data.page)
                } label: {
                    Text("Page")
                }
                
                LabeledContent {
                    Text(data.address)
                } label: {
                    Text("Address")
                }
                
                LabeledContent {
                    data.isSecure != 0 ? Text("Yes") : Text("No")
                } label: {
                    Text("Is Secure")
                }
                
                LabeledContent {
                    Text(data.format)
                } label: {
                    Text("Format")
                }
                
                LabeledContent {
                    Text("\(data.responseTime) ms")
                } label: {
                    Text("Response Time")
                }
                
                LabeledContent {
                    Text(data.httpStatus)
                } label: {
                    Text("Status Code")
                }
            }
            
            Group {
                LabeledContent {
                    if data.age != "" {
                        Text("\(data.age) s")
                    }
                } label: {
                    Text("Age")
                }
                
                LabeledContent {
                    Text(data.cacheControl)
                } label: {
                    Text("Cache Control")
                }
                
                LabeledContent {
                    Text(data.eTag)
                } label: {
                    Text("ETag")
                }
                
                LabeledContent {
                    Text(data.server)
                } label: {
                    Text("Server")
                }
            }
        }
    }
}
