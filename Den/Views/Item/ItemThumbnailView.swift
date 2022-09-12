//
//  ItemThumbnailView.swift
//  Den
//
//  Created by Garrett Johnson on 4/17/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct ItemThumbnailView: View {
    let item: Item

    var body: some View {
        if item.image != nil {
            AsyncImage(url: item.image) { image in
                image.resizable().aspectRatio(item.imageAspectRatio, contentMode: .fill)
            } placeholder: {
                placeholder
            }
            .modifier(ThumbnailModifier())
        } else if item.feedData?.image != nil {
            AsyncImage(url: item.feedData?.image) { image in
                image.resizable().aspectRatio(item.imageAspectRatio, contentMode: .fit)
            } placeholder: {
                placeholder
            }
            .padding(6)
            .modifier(ThumbnailModifier())
        }
    }

    var placeholder: some View {
        Image(systemName: "photo")
            .foregroundColor(Color(UIColor.tertiaryLabel))
    }
}
