//
//  FeedUnavailableView.swift
//  Den
//
//  Created by Garrett Johnson on 12/2/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedUnavailableView: View {
    let feedData: FeedData?
    var splashNote: Bool = false

    var body: some View {
        HStack(alignment: .top) {
            if feedData == nil {
                FeedStatusView(
                    title: "No Data",
                    caption: "Refresh to get content",
                    splashNote: splashNote
                )
            } else if let error = feedData?.error {
                FeedStatusView(
                    title: "Refresh Error",
                    caption: error,
                    symbolColor: .red,
                    splashNote: splashNote
                )
            } else if feedData!.itemsArray.isEmpty {
                FeedStatusView(
                    title: "Feed Empty",
                    caption: "No items",
                    splashNote: splashNote
                )
            } else {
                FeedStatusView(
                    title: "Status Unavailable",
                    splashNote: splashNote
                )
            }
        }
    }
}
