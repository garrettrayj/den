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
    let item: Item

    var body: some View {
        if item.image != nil {
            WebImage(url: item.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.thumbnail])
                .resizable()
                .purgeable(true)
                .placeholder {
                    Image(systemName: "photo")
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .playbackRate(0)
                .aspectRatio(item.imageAspectRatio, contentMode: .fill)
                .modifier(ThumbnailModifier())
        } else if item.feedData?.image != nil {
            WebImage(url: item.feedData?.image, context: [.imageThumbnailPixelSize: ImageReferenceSize.thumbnail])
                .resizable()
                .purgeable(true)
                .placeholder {
                    Image(systemName: "photo")
                        .foregroundColor(Color(UIColor.tertiaryLabel))
                }
                .playbackRate(0)
                .scaledToFit()
                .padding(6)
                .modifier(ThumbnailModifier())
        }
    }
}
