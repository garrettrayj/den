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
            if feedData == nil {
                Label("Refresh to Load Content", systemImage: "arrow.clockwise")
            } else if feedData?.error != nil {
                Label {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Refresh Error")
                        Text(feedData!.error!).font(.callout).foregroundColor(.red)
                    }
                } icon: {
                    Image(systemName: "exclamationmark.triangle")
                }
            } else if feedData!.itemsArray.count == 0 {
                Label("Feed Empty", systemImage: "questionmark.folder")
            } else {
                Label("Feed Status Unavailable", systemImage: "questionmark.diamond")
            }
        }
        .imageScale(.medium)
        .foregroundColor(.secondary)
    }
}
