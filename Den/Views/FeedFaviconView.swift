//
//  FeedFaviconView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedFaviconView: View {
    let url: URL?

    var body: some View {
        WebImage(url: url, context: [.imageThumbnailPixelSize: ImageReferenceSize.favicon])
            .resizable()
            .placeholder {
                Image(systemName: "dot.radiowaves.up.forward").imageScale(.medium)
            }
            .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
    }
}
