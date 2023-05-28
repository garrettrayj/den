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
    let feedData: FeedData?

    var titleFont: Font = .body
    var subtitleFont: Font = .caption

    var body: some View {
        VStack(spacing: 4) {
            if feedData == nil {
                Text("No Data").font(titleFont)
                Text("Refresh to fetch content.").font(subtitleFont)
            } else if let error = feedData?.wrappedError {
                Text("Refresh Error").font(titleFont)
                if error == .request {
                    Text("Unable to fetch content.").font(subtitleFont)
                } else {
                    Text("Unable to parse content.").font(subtitleFont)
                }
            } else if feedData!.itemsArray.isEmpty {
                Text("Feed Empty").font(titleFont)
                Text("No items to display.").font(subtitleFont)
            } else {
                Text("Status Unavailable").font(titleFont)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
