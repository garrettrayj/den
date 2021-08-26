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
                    .scaleEffect(1 / UIScreen.main.scale)
                    .frame(width: 16, height: 16, alignment: .center)
                    .clipped()
            } else {
                Image(uiImage: UIImage(named: "RSSIcon")!)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color.secondary)
                    .frame(width: 14, height: 14, alignment: .center)
            }
        }
    }
}
