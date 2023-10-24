//
//  LargeThumbnail.swift
//  Den
//
//  Created by Garrett Johnson on 8/3/22.
//  Copyright © 2022 Garrett Johnson
//

import SwiftUI

import SDWebImageSwiftUI

struct LargeThumbnail: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.largeThumbnailSize) private var largeThumbnailSize
    @Environment(\.largeThumbnailPixelSize) private var largeThumbnailPixelSize

    let url: URL
    let isRead: Bool

    let width: CGFloat?
    let height: CGFloat?

    var aspectRatio: CGFloat? {
        guard
            let width = width,
            let height = height,
            width > 0,
            height > 0
        else { return nil }

        return width / height
    }

    var body: some View {
        Group {
            if aspectRatio == nil {
                ImageDepression(padding: 8) {
                    VStack {
                        WebImage(
                            url: url,
                            options: [.delayPlaceholder, .lowPriority],
                            context: [.imageThumbnailPixelSize: largeThumbnailPixelSize]
                        )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(isRead ? 0.5 : 0))
                        .modifier(ImageBorderModifier(cornerRadius: 4))
                        .scaledToFit()
                    }
                }
                .aspectRatio(16/9, contentMode: .fill)
            } else if aspectRatio! < 0.5 {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: url,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: largeThumbnailPixelSize]
                    )
                        .resizable()
                        .placeholder { ImageErrorPlaceholder() }
                        .grayscale(isEnabled ? 0 : 1)
                        .overlay(.background.opacity(isRead ? 0.5 : 0))
                        .aspectRatio(aspectRatio, contentMode: .fit)
                        .frame(
                            maxHeight: largeThumbnailSize.height > 0 ? min(largeThumbnailSize.height, 400) : nil,
                            alignment: .top
                        )
                }
            } else if let width = width, width < largeThumbnailSize.width {
                ImageDepression(padding: 8) {
                    WebImage(
                        url: url,
                        options: [.delayPlaceholder, .lowPriority],
                        context: [.imageThumbnailPixelSize: largeThumbnailPixelSize]
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
                    context: [.imageThumbnailPixelSize: largeThumbnailPixelSize]
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
