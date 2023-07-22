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
    @Environment(\.displayScale) private var displayScale
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let url: URL?

    let baseSize = CGSize(width: 16, height: 16)

    private var scaledSize: CGSize {
        return CGSize(
            width: baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * displayScale,
            height: scaledSize.height * displayScale
        )
    }

    var body: some View {
        WebImage(
            url: url,
            options: [.decodeFirstFrameOnly],
            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
        )
        .resizable()
        .purgeable(true)
        .placeholder {
            Image(systemName: "dot.radiowaves.up.forward")
                .resizable()
                .foregroundColor(.primary)
                .padding(2)
        }
        .scaledToFit()
        .frame(width: scaledSize.width, height: scaledSize.height)
        .grayscale(isEnabled ? 0 : 1)
    }
}
