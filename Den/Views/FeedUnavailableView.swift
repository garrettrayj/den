//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedUnavailableView: View {
    var feedData: FeedData?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Group {
                if feedData == nil {
                    Label("Refresh to load items", systemImage: "arrow.clockwise")
                } else if feedData?.error != nil {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Unable to update feed")
                            Text(feedData!.error!).font(.callout).foregroundColor(.red)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle")
                    }
                } else if feedData!.itemsArray.count == 0 {
                    Label("Feed empty", systemImage: "questionmark.folder")
                } else {
                    Label("Unknown status", systemImage: "questionmark.diamond")
                }
            }
            .imageScale(.medium)
            .foregroundColor(.secondary)
        }
    }
}
