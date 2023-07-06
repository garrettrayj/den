//
//  FeedTitleLabel.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

struct FeedTitleLabel: View {
    @ObservedObject var feed: Feed

    var body: some View {
        Label {
            feed.titleText
        } icon: {
            FeedFavicon(url: feed.feedData?.favicon)
        }
        .lineLimit(1)
    }
}
