//
//  FeedHeroView.swift
//  Den
//
//  Created by Garrett Johnson on 2/9/23.
//  Copyright © 2023 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedHeroView: View {
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @Environment(\.contentSizeCategory) private var contentSizeCategory

    let heroImage: URL

    static let baseSize = CGSize(width: 320, height: 180)

    private var typeSize: DynamicTypeSize {
        DynamicTypeSize(contentSizeCategory) ?? dynamicTypeSize
    }

    private var scaledSize: CGSize {
        return CGSize(
            width: FeedHeroView.baseSize.width * typeSize.fontScale,
            height: FeedHeroView.baseSize.height * typeSize.fontScale
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * UIScreen.main.scale,
            height: scaledSize.height * UIScreen.main.scale
        )
    }

    private var maxHeight: CGFloat {
        scaledSize.height + 40
    }

    var body: some View {
        VStack(spacing: 0) {
            WebImage(url: heroImage, context: [.imageThumbnailPixelSize: thumbnailPixelSize])
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .shadow(radius: 3, x: 1, y: 2)
                .frame(maxWidth: scaledSize.width, maxHeight: scaledSize.height)
                .padding(20)
        }
        .aspectRatio(16/9, contentMode: .fill)
        .frame(maxWidth: .infinity, maxHeight: maxHeight)
        .background {
            WebImage(url: heroImage)
                .resizable()
                .scaledToFill()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .overlay(.thinMaterial)
        }
        .clipped()
    }
}
