//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedTitleLabelView: View {
    @ObservedObject var feed: Feed

    var body: some View {
        Label {
            Text(feed.wrappedTitle).lineLimit(1)
        } icon: {
            if feed.feedData?.faviconImage != nil {
                feed.feedData!.faviconImage!
                    .resizable()
                    .scaledToFill()
                    .frame(width: 16, height: 16)
            } else {
                Image(systemName: "dot.radiowaves.up.forward")
                    .foregroundColor(Color.secondary)
            }
        }
    }
}
