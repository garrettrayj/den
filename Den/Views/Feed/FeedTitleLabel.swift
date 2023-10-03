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

import SDWebImageSwiftUI

struct FeedTitleLabel: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.faviconSize) private var faviconSize
    @Environment(\.faviconPixelSize) private var faviconPixelSize

    @ObservedObject var feed: Feed

    var body: some View {
        Label {
            feed.titleText.lineLimit(1)
        } icon: {
            WebImage(
                url: feed.feedData?.favicon,
                options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
                context: [.imageThumbnailPixelSize: faviconPixelSize]
            )
            .resizable()
            .placeholder {
                Image(systemName: "dot.radiowaves.up.forward").foregroundStyle(.primary)
            }
            .scaledToFit()
            .frame(width: faviconSize.width, height: faviconSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .grayscale(isEnabled ? 0 : 1)
        }
    }
}
