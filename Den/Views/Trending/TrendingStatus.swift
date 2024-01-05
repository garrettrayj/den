//
//  TrendingStatus.swift
//  Den
//
//  Created by Garrett Johnson on 1/5/24.
//  Copyright © 2024 Garrett Johnson
//

import SwiftUI

struct TrendingStatus: View {
    @ObservedObject var profile: Profile
    
    var body: some View {
        VStack {
            Group {
                if profile.trends.isEmpty {
                    Text("No Trends", comment: "Status message.")
                } else if profile.trends.containingUnread().isEmpty {
                    Text("All Read", comment: "Status message.")
                } else {
                    Text(
                        "\(profile.trends.containingUnread().count) with Unread",
                        comment: "Status message."
                    )
                }
            }
            .lineLimit(1)
            .font(.caption)

            if let refreshedDate = RefreshedDateStorage.getRefreshed(profile) {
                RelativeRefreshedDate(date: refreshedDate)
                    .lineLimit(1)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
