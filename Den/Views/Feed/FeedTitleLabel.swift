//
//  FeedTitleLabel.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedTitleLabel: View {
    @ObservedObject var feed: Feed
    
    var body: some View {
        Label {
            Text(feed.wrappedTitle).lineLimit(1)
        } icon: {
            FaviconImage(url: feed.feedData?.favicon, size: .medium)
        }
    }
}
