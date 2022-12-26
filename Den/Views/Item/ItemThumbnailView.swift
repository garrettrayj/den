//
//  ItemThumbnailView.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct ItemThumbnailView: View {
    @Environment(\.isEnabled) private var isEnabled

    let item: Item

    var body: some View {
        if let image = item.image {
            WebImage(url: image, context: [.imageThumbnailPixelSize: ImageReferenceSize.thumbnail])
                .resizable()
                .placeholder {
                    placeholder
                }
                .playbackRate(0)
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .modifier(ThumbnailModifier())
                .grayscale(isEnabled ? 0 : 1)
                .opacity(isEnabled ? 1 : UIConstants.dimmedImageOpacity)
        } else if let image = item.feedData?.image {
            WebImage(url: image, context: [.imageThumbnailPixelSize: ImageReferenceSize.thumbnail])
                .resizable()
                .purgeable(true)
                .placeholder {
                    placeholder
                }
                .playbackRate(0)
                .aspectRatio(item.imageAspectRatio, contentMode: .fit)
                .cornerRadius(4)
                .padding(4)
                .modifier(ThumbnailModifier())
                .grayscale(isEnabled ? 0 : 1)
                .opacity(isEnabled ? 1 : UIConstants.dimmedImageOpacity)
        }
    }

    var placeholder: some View {
        Image(systemName: "photo")
            .foregroundColor(Color(UIColor.tertiaryLabel))
    }
}
