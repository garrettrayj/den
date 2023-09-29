//
//  FeedFavicon.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedFavicon: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.faviconSize) private var faviconSize
    @Environment(\.faviconPixelSize) private var faviconPixelSize

    let url: URL?

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
            context: [.imageThumbnailPixelSize: faviconPixelSize]
        )
        .resizable()
        .placeholder {
            Image(systemName: "dot.radiowaves.up.forward")
                .foregroundStyle(.primary)
        }
        .scaledToFit()
        .frame(width: faviconSize.width, height: faviconSize.height)
        .clipShape(RoundedRectangle(cornerRadius: 2))
        .grayscale(isEnabled ? 0 : 1)
    }
}
