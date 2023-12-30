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
    #if os(macOS)
    @Environment(\.controlActiveState) private var controlActiveState
    #endif
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.faviconSize) private var faviconSize
    @Environment(\.faviconPixelSize) private var faviconPixelSize

    @ObservedObject var feed: Feed
    
    private var opacity: CGFloat {
        #if os(macOS)
        if controlActiveState == .inactive || !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #else
        if !isEnabled {
            return 0.4
        } else {
            return 1
        }
        #endif
    }
    
    var body: some View {
        Label {
            feed.titleText.lineLimit(1)
        } icon: {
            WebImage(
                url: feed.feedData?.favicon,
                options: [.decodeFirstFrameOnly, .delayPlaceholder],
                context: [.imageThumbnailPixelSize: faviconPixelSize]
            ) { image in
                image.resizable().scaledToFit()
            } placeholder: {
                Image(systemName: "dot.radiowaves.up.forward").foregroundStyle(.primary)
            }
            .frame(width: faviconSize.width, height: faviconSize.height)
            .clipShape(RoundedRectangle(cornerRadius: 2))
            .opacity(opacity)
        }
    }
}
