//
//  FeedFaviconView.swift
//  Den
//
//  Created by Garrett Johnson on 7/2/22.
//  Copyright © 2022 Garrett Johnson. All rights reserved.
//

import SwiftUI

struct FeedFaviconView: View {
    let url: URL?

    var placeholderSymbol: String = "dot.radiowaves.up.forward"

    var body: some View {
        AsyncImage(url: url) { image in
            image.resizable()
        } placeholder: {
            Image(systemName: placeholderSymbol).imageScale(.medium)
        }
        .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
    }
}
