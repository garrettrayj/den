//
//  ThumbnailView.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ThumbnailView: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentSizeCategory) private var contentSizeCategory

    let item: Item

    static let baseSize = CGSize(width: 64, height: 64)

    private var scaledSize: CGSize {
        return CGSize(
            width: ThumbnailView.baseSize.width * dynamicTypeSize.fontScale,
            height: ThumbnailView.baseSize.height * dynamicTypeSize.fontScale
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    var body: some View {
        Group {
            if let image = item.image {
                WebImage(
                    url: image,
                    options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                    .resizable()
                    .purgeable(true)
                    .placeholder { ImagePlaceholderView(imageScale: .medium) }
                    .indicator(.activity)
                    .aspectRatio(item.imageAspectRatio, contentMode: .fill)

            } else if let image = item.feedData?.image {
                WebImage(
                    url: image,
                    options: [.decodeFirstFrameOnly, .delayPlaceholder, .lowPriority],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                    .resizable()
                    .purgeable(true)
                    .placeholder { ImagePlaceholderView(imageScale: .medium) }
                    .indicator(.activity)
                    .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                    .cornerRadius(4)
                    .padding(4)
            }
        }
        .grayscale(isEnabled ? 0 : 1)
        .opacity(isEnabled ? 1 : AppDefaults.dimmedImageOpacity)
        .frame(width: scaledSize.width, height: scaledSize.height)
        .background(Color(UIColor.tertiarySystemFill))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6).stroke(Color(UIColor.separator), lineWidth: 1)
        )
    }
}
