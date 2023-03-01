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
        if let image = item.image {
            WebImage(url: image, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                .resizable()
                .purgeable(true)
                .playbackRate(0)
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .grayscale(isEnabled ? 0 : 1)
                .opacity(isEnabled ? 1 : AppDefaults.dimmedImageOpacity)
                .modifier(ThumbnailModifier(width: scaledSize.width, height: scaledSize.height))
        } else if let image = item.feedData?.image {
            WebImage(url: image, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                .resizable()
                .purgeable(true)
                .playbackRate(0)
                .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                .cornerRadius(4)
                .padding(4)
                .grayscale(isEnabled ? 0 : 1)
                .opacity(isEnabled ? 1 : AppDefaults.dimmedImageOpacity)
                .modifier(ThumbnailModifier(width: scaledSize.width, height: scaledSize.height))
        }
    }

    var placeholder: some View {
        Image(systemName: "photo").foregroundColor(Color(UIColor.tertiaryLabel))
    }
}
