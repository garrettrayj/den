//
//  FeedFaviconView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedFaviconView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentSizeCategory) private var contentSizeCategory

    let url: URL?

    var placeholderSymbol: String = "dot.radiowaves.up.forward"

    let baseSize = CGSize(width: 16, height: 16)

    private var scaledSize: CGSize {
        return CGSize(
            width: baseSize.width * dynamicTypeSize.fontScale,
            height: baseSize.height * dynamicTypeSize.fontScale
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    var body: some View {
        WebImage(url: url, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
            .resizable()
            .playbackRate(0)
            .placeholder {
                Image(systemName: placeholderSymbol)
                    .font(.system(size: 15).weight(.semibold))
                    .foregroundColor(.primary)
            }
            .frame(width: scaledSize.width, height: scaledSize.height)
            .grayscale(isEnabled ? 0 : 1)
            .opacity(isEnabled ? 1 : UIConstants.dimmedImageOpacity)
    }
}
