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
    @Environment(\.isEnabled) private var isEnabled
    
    let url: URL?

    var placeholderSymbol: String = "dot.radiowaves.up.forward"
    var purgeable: Bool = true
    var dimmed: Bool = false

    var body: some View {
        WebImage(url: url, context: [.imageThumbnailPixelSize: ImageReferenceSize.favicon])
            .resizable()
            .playbackRate(0)
            .placeholder {
                Image(systemName: "dot.radiowaves.up.forward")
                    .font(.system(size: 15).weight(.semibold))
                    .foregroundColor(.primary)
            }
            .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
            .grayscale(isEnabled ? 0 : 1)
            .opacity(isEnabled && !dimmed ? 1 : UIConstants.dimmedImageOpacity)
    }
}
