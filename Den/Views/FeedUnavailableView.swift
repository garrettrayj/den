//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedUnavailableView: View {
    @ObservedObject var feed: Feed

    var body: some View {

        VStack(alignment: .leading, spacing: 4) {
            Group {
                if feed.feedData == nil {
                    Label("Refresh to load items", systemImage: "arrow.clockwise")
                } else if feed.feedData?.error != nil {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unable to update feed")
                            Text(feed.feedData!.error!).font(.callout).foregroundColor(.red)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.circle")
                    }
                } else if feed.feedData!.itemsArray.count == 0 {
                    Label("Feed empty", systemImage: "square.slash")
                } else {
                    Label("Unknown status", systemImage: "questionmark.diamond")
                }
            }
            .imageScale(.medium)
            .foregroundColor(.secondary)
        }
    }
}
