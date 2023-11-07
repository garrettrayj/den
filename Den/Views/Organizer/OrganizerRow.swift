//
//  OrganizerRow.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//

import SwiftUI

struct OrganizerRow: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        HStack {
            FeedTitleLabel(feed: feed)
            Spacer()
            Group {
                if feed.feedData == nil {
                    Image(systemName: "questionmark.folder").foregroundStyle(.yellow)
                    Text("No Data", comment: "Organizer row status.")
                } else if let error = feed.feedData?.wrappedError {
                    Image(systemName: "bolt.horizontal").foregroundStyle(.red)
                    switch error {
                    case .parsing:
                        Text("Parsing Error", comment: "Organizer row status.")
                    case .request:
                        Text("Network Error", comment: "Organizer row status.")
                    }
                } else if let responseTime = feed.feedData?.responseTime {
                    if responseTime > 5 {
                        Image(systemName: "tortoise").foregroundStyle(.brown)
                    } else if !feed.isSecure {
                        Image(systemName: "lock.slash").foregroundStyle(.orange)
                    }
                    Text(
                        "\(Int(responseTime * 1000)) ms",
                        comment: "Request response time (milliseconds)."
                    )
                }
            }
            .font(.callout)
            .imageScale(.medium)
            .foregroundStyle(.secondary)
        }
        .tag(feed)
    }
}
