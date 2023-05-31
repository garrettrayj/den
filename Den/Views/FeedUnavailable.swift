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

    var titleFont: Font = .body
    var subtitleFont: Font = .caption

    var body: some View {
        VStack(spacing: 4) {
            if feedData == nil {
                Text("No Data", comment: "Feed unavailable header").font(titleFont)
                Text("Refresh to fetch content.", comment: "Feed unavailable note").font(subtitleFont)
            } else if let error = feedData?.wrappedError {
                Text("Refresh Error", comment: "Feed unavailable header").font(titleFont)
                if error == .request {
                    Text("Unable to fetch content.", comment: "Feed unavailable note").font(subtitleFont)
                } else {
                    Text("Unable to parse content.", comment: "Feed unavailable note").font(subtitleFont)
                }
            } else if feedData!.itemsArray.isEmpty {
                Text("Feed Empty", comment: "Feed unavailable header").font(titleFont)
                Text("No items to display.", comment: "Feed unavailable note").font(subtitleFont)
            } else {
                Text("Status Unavailable", comment: "Feed unavailable header").font(titleFont)
            }
        }
        .foregroundColor(isEnabled ? .primary : .secondary)
        .frame(maxWidth: .infinity)
    }
}
