//
//  OrganizerRow.swift
//  Den
//
//  Created by Garrett Johnson on 11/7/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct OrganizerRow: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        HStack {
            FeedTitleLabel(feed: feed)
            Spacer()
            Group {
                if let feedData = feed.feedData {
                    OrganizerRowStatus(feed: feed, feedData: feedData)
                } else {
                    Image(systemName: "questionmark.folder").foregroundStyle(.yellow)
                    Text("No Data", comment: "Organizer row status.")
                }
            }
            .font(.callout)
            .imageScale(.medium)
            .foregroundStyle(.secondary)
        }
        .lineLimit(1)
        .tag(feed)
    }
}
