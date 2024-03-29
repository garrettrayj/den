//
//  TrendingStatus.swift
//  Den
//
//  Created by Garrett Johnson on 1/5/24.
//  Copyright © 2024 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct TrendingStatus: View {
    @ObservedObject var profile: Profile
    
    let trends: FetchedResults<Trend>
    
    var body: some View {
        VStack {
            Group {
                if trends.isEmpty {
                    Text("No Trends", comment: "Status message.")
                } else if trends.containingUnread().isEmpty {
                    Text("All Read", comment: "Status message.")
                } else {
                    Text(
                        "\(trends.containingUnread().count) with Unread",
                        comment: "Status message."
                    )
                }
            }
            
            .font(.caption)

            if let refreshedDate = RefreshedDateStorage.getRefreshed(profile.id?.uuidString) {
                RelativeRefreshedDate(date: refreshedDate)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .lineLimit(1)
    }
}
