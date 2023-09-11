//
//  OrganizerFeedStatus.swift
//  Den
//
//  Created by Garrett Johnson on 9/11/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerFeedStatus: View {
    @ObservedObject var feed: Feed

    var body: some View {
        HStack(spacing: 4) {
            if feed.feedData == nil {
                Text("No Data")
                Image(systemName: "circle.slash").foregroundStyle(.yellow)
            } else if let error = feed.feedData?.wrappedError {
                switch error {
                case .parsing:
                    Text("Parsing Error")
                case .request:
                    Text("Network Error")
                }
                Image(systemName: "bolt.horizontal").foregroundStyle(.red)
            } else if let responseTime = feed.feedData?.responseTime {
                Text("\(Int(responseTime * 1000)) ms")
                if !feed.isSecure {
                    Image(systemName: "lock.slash").foregroundStyle(.orange)
                }
            }
        }
        .font(.callout)
        .foregroundStyle(.secondary)
    }
}
