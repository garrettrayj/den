//
//  FeedTitleLabel.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedTitleLabel: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        Label {
            feed.displayTitle.lineLimit(1)
        } icon: {
            Favicon(url: feed.feedData?.favicon) {
                FeedFaviconPlaceholder()
            }
        }
    }
}
