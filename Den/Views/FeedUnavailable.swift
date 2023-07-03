//
//  FeedUnavailable.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUnavailable: View {
    @Environment(\.isEnabled) var isEnabled

    let feedData: FeedData?

    var body: some View {
        VStack(spacing: 4) {
            if feedData == nil {
                Text("No Data", comment: "Feed unavailable message.")
                Text("Refresh to get content.", comment: "Feed unavailable message.").font(.caption)
            } else if let error = feedData?.wrappedError {
                Image(systemName: "exclamationmark.triangle").imageScale(.large).padding(.bottom, 4)
                Text("Refresh Failed", comment: "Feed unavailable message.")
                if error == .request {
                    Text("Could not fetch data.", comment: "Feed unavailable message.")
                        .font(.caption)
                } else {
                    Text("Unable to parse content.", comment: "Feed unavailable message.")
                        .font(.caption)
                }
            } else if feedData!.itemsArray.isEmpty {
                Text("Feed Empty", comment: "Feed unavailable message.")
            } else {
                Text("Feed Unavailable", comment: "Feed unavailable message.")
            }
        }
        .multilineTextAlignment(.center)
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity)
        .padding()
    }
}
