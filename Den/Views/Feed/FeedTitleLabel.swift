//
//  FeedTitleLabel.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson
//
//  SPDX-License-Identifier: NONE
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedTitleLabel: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        Label {
            feed.displayTitle.lineLimit(1)
        } icon: {
            if let feedData = feed.feedData {
                FeedFavicon(feedData: feedData)
            } else {
                FeedFaviconPlaceholder()
            }
        }
    }
}
