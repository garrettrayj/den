//
//  ItemPreviewImage.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//
//  SPDX-License-Identifier: MIT
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemPreviewImage: View {
    @Environment(\.displayScale) private var displayScale
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    let url: URL
    let isRead: Bool
    let aspectRatio: CGFloat?
    let width: CGFloat?
    let height: CGFloat?

    static let baseSize = CGSize(width: 384, height: 216)

    private var scaledSize: CGSize {
        return CGSize(
            width: ItemPreviewImage.baseSize.width * dynamicTypeSize.layoutScalingFactor,
            height: ItemPreviewImage.baseSize.height * dynamicTypeSize.layoutScalingFactor
        )
    }

    private var thumbnailPixelSize: CGSize {
        CGSize(
            width: scaledSize.width * displayScale,
            height: scaledSize.height * displayScale
        )
    }

    var body: some View {
        ZStack {
            if aspectRatio == nil {
                ImageDepression(padding: 8) {
                    VStack {
                        WebImage(
                            url: url,
                            options: [.delayPlaceholder, .lowPriority],
                            context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                        )
                            .resizable()
                            .placeholder { ImageErrorPlaceholder() }
                            .grayscale(isEnabled ? 0 : 1)
                            .overlay(.background.opacity(isRead ? 0.5 : 0))
                            .modifier(ImageBorderModifier(cornerRadius: 4))
                            .scaledToFit()
                    }
                    .aspectRatio(16/9, contentMode: .fill)
                }
            } else if aspectRatio! < 0.5 {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: url,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(isRead ? 0.5 : 0))
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .frame(
                            maxHeight: scaledSize.height > 0 ? min(scaledSize.height, 400) : nil,
                            alignment: .top
                        )
                }
            } else if let width = width, width < scaledSize.width {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: url,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(isRead ? 0.5 : 0))
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .clipped()
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                }
            } else {
                WebImage(
                    url: url,
                    options: [.delayPlaceholder, .lowPriority],
                    context: [.imageThumbnailPixelSize: thumbnailPixelSize]
                )
                .resizable()
                .placeholder { ImageErrorPlaceholder() }
                .grayscale(isEnabled ? 0 : 1)
                .overlay(.background.opacity(isRead ? 0.5 : 0))
                .aspectRatio(aspectRatio, contentMode: .fit)
                .background(.quaternary)
                .modifier(ImageBorderModifier(cornerRadius: 6))
            }
        }
        .accessibility(label: Text("Preview Image", comment: "Accessibility label."))
    }
}
