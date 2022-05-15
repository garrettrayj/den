//
//  FeedTitleLabelView.swift
//  Den
//
//  Created by Garrett Johnson on 8/23/21.
//  Copyright © 2021 Garrett Johnson. All rights reserved.
//

import SwiftUI

import SDWebImageSwiftUI

struct FeedTitleLabelView: View {
    var title: String
    var favicon: URL?

    var body: some View {
        Label {
            Text(title).lineLimit(1)
        } icon: {
            WebImage(url: favicon)
                .resizable()
                .placeholder {
                    Image(systemName: "dot.radiowaves.up.forward")
                }
                .frame(width: ImageSize.favicon.width, height: ImageSize.favicon.height)
        }
    }
}
